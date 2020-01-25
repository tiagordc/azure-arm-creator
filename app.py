import os, re, time
from json import load as load_json
from flask import Flask, render_template, send_from_directory, send_file, jsonify, abort, request
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.resource.resources.models import DeploymentMode
from auth import admin_required, auth_required
from utils import icon_for_template
from base64 import b64encode

app = Flask(__name__)

template_folder = os.environ['ARM_TEMPLATE_FOLDER']
azure_subscription_id = os.environ['AZURE_SUBSCRIPTION_ID']
azure_client_id = os.environ['AZURE_CLIENT_ID']
azure_client_secret = os.environ['AZURE_CLIENT_SECRET']
azure_tenant_id = os.environ['AZURE_TENANT_ID']

credentials = ServicePrincipalCredentials(client_id=azure_client_id, secret=azure_client_secret, tenant=azure_tenant_id)
resource_client = ResourceManagementClient(credentials, azure_subscription_id)
compute_client = ComputeManagementClient(credentials, azure_subscription_id)
network_client = NetworkManagementClient(credentials, azure_subscription_id)

@app.route('/static/<path:path>', methods=['GET'])
def static_files(path):
	"""Serve static files from the static folders"""
	return send_from_directory('static', path)

@app.route('/admin', methods=['GET'])
@admin_required
def admin():
	"""Admin Page"""
	return render_template('admin.html')

@app.route('/templates', methods=['GET'])
@admin_required
def templates():
	"""List available templates"""
	result = []
	for root, dirs, files in os.walk(template_folder):
		if root.startswith(template_folder) and "template.json" in files:
			template_path = root[len(template_folder)+1:]
			template_image = icon_for_template(template_folder, template_path)
			if template_image == None:
				break
			template_image = os.path.basename(template_image)
			item_name, img_ext = os.path.splitext(template_image)
			item = { "name": item_name, "path": template_path }
			result.append(item)
	return jsonify(result)

@app.route('/groups', methods=['GET'])
@admin_required
def groups():
	"""List created resource groups"""
	groups = resource_client.resource_groups.list(filter="tagName eq 'created-by' and tagValue eq '" + os.environ['ARM_CREATED_TAG'] + "'")
	result = [x.name for x in groups]
	return jsonify(result)

@app.route('/template/<template>/parameters', methods=['GET'])
@admin_required
def parameters(template):
	"""Get template parameters"""
	template_path = os.path.join(os.path.dirname(__file__), template_folder, template, 'template.json')
	with open(template_path, 'r') as template_file_fd:
		template_file = load_json(template_file_fd)
	parameters = template_file['parameters']
	if 'Server_URL' in parameters:
		del parameters['Server_URL'] 
	return jsonify(parameters)

@app.route('/template/<template>/icon', methods=['GET'])
def icon(template):
	"""Get template icon"""
	icon = icon_for_template(template_folder, template)
	if icon:
		return send_file(icon)
	abort(404)

@app.route('/template/<template>/deploy', methods=['POST'])
@admin_required
def deploy(template):
	"""Deploy a new resource group based on a template and some given parameters"""
	parameters = request.get_json()
	parameters['Server_URL'] = request.url_root
	group_name = parameters['Resource_Group_Name']
	tags = {'created-by': os.environ['ARM_CREATED_TAG'] }
	if 'Resource_Group_Admin' in parameters and 'Resource_Group_Password' in parameters:
		userpass = parameters['Resource_Group_Admin'] + ":" + parameters['Resource_Group_Password']
		tags[os.environ['ARM_AUTH_TAG']] = b64encode(userpass.encode())
	parameters = {k: {'value': v} for k, v in parameters.items() }
	location = os.environ['AZURE_LOCATION']
	resource_group_params = {'location':location}
	resource_client.resource_groups.create_or_update(group_name, resource_group_params)
	template_path = os.path.join(os.path.dirname(__file__), template_folder, template, 'template.json')
	with open(template_path, 'r') as template_file_fd:
		template_file = load_json(template_file_fd)
	deployment_properties = { 'mode': DeploymentMode.incremental, 'template': template_file, 'parameters': parameters }
	deployment_async_operation = resource_client.deployments.create_or_update(group_name, 'arm-deployment', deployment_properties)
	deployment_async_operation.wait()
	resource_group_params.update(tags=tags)
	resource_client.resource_groups.update(group_name, resource_group_params)
	return '', 200

@app.route('/<resource_group>/delete', methods=['POST'])
@admin_required
def delete(resource_group):
	"""Delete resource group"""
	group = resource_client.resource_groups.get(resource_group)
	resource_group_params = {'location': group.location}
	resource_group_params.update(tags={})
	resource_client.resource_groups.update(resource_group, resource_group_params)
	async_rg_delete = resource_client.resource_groups.delete(resource_group)
	async_rg_delete.wait()
	return '', 200

@app.route('/<resource_group>/admin', methods=['GET'])
@auth_required(resource_client)
def resource(resource_group):
	"""Resource group page"""
	return render_template('resource.html')

@app.route('/<resource_group>/vms', methods=['GET'])
@auth_required(resource_client)
def machines(resource_group):
	"""List resource group machines"""
	result = []
	for vm in compute_client.virtual_machines.list(resource_group):
		instance = compute_client.virtual_machines.instance_view(resource_group, vm.name)
		vm_power = 'unknown'
		power_state = [x.code[x.code.index('/')+1:] for x in instance.statuses if x.code.startswith('PowerState')]
		if len(power_state) > 0:
			vm_power = power_state[0] 
		vm_private_ips = []
		vm_public_ips = []
		for nic in vm.network_profile.network_interfaces:
			nic_id = re.search("/resourceGroups/([^/]+).*/networkInterfaces/([^/]+).*", nic.id, re.DOTALL)
			nic_details = network_client.network_interfaces.get(nic_id.group(1), nic_id.group(2))
			for ip in nic_details.ip_configurations:
				if ip.private_ip_address:
					vm_private_ips.append(ip.private_ip_address)
				if ip.public_ip_address and ip.public_ip_address.id:
					public_ip_id = re.search("/resourceGroups/([^/]+).*/publicIPAddresses/([^/]+).*", ip.public_ip_address.id, re.DOTALL)
					public_ip = network_client.public_ip_addresses.get(public_ip_id.group(1), public_ip_id.group(2))
					if public_ip.ip_address:
						vm_public_ips.append(public_ip.ip_address)
		if vm.os_profile and vm.os_profile.admin_username:
			vm_admin = vm.os_profile.admin_username
		vm_os = 'unknown'
		if vm.os_profile.windows_configuration:
			vm_os = 'windows'
		if vm.os_profile.linux_configuration:
			vm_os = 'linux'
		result.append({ "name": vm.name, "status": vm_power, "public": vm_public_ips, "private": vm_private_ips, "admin": vm_admin, "tags": vm.tags, "os": vm_os })
	return jsonify(result)

@app.route('/<resource_group>/<machine>/stop', methods=['POST'])
@auth_required(resource_client)
def stop(resource_group, machine):
	"""Stop VM to an deallocated state"""
	async_vm_deallocate = compute_client.virtual_machines.deallocate(resource_group, machine)
	async_vm_deallocate.wait()
	return '', 200

@app.route('/<resource_group>/<machine>/start', methods=['POST'])
@auth_required(resource_client)
def start(resource_group, machine):
	"""Start VM"""
	async_vm_start = compute_client.virtual_machines.start(resource_group, machine)
	async_vm_start.wait()
	return '', 200

@app.route('/<resource_group>/<machine>/scale/<size>', methods=['POST'])
def scale_vm(resource_group, machine, size):
	"""Scale VM to a given size"""
	if size.startswith("B1"): # Hard coding B1 options only
		vm = compute_client.virtual_machines.get(resource_group, machine)
		vm.hardware_profile.vm_size = size
		update_result = compute_client.virtual_machines.create_or_update(resource_group, machine, vm)
		update_result.wait()
	else:
		time.sleep(30)
	return '', 200

if __name__ == '__main__':
	app.run()
