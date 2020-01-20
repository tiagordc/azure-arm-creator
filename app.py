import os, re
from json import load as load_json
from flask import Flask, render_template, send_from_directory, send_file, jsonify, abort, request
from azure.common.credentials import ServicePrincipalCredentials
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network import NetworkManagementClient
from auth import admin_required, auth_required
from PIL import Image

app = Flask(__name__)

template_folder = os.environ['ARM_TEMPLATE_FOLDER']
credentials = ServicePrincipalCredentials(client_id=os.environ['AZURE_CLIENT_ID'], secret=os.environ['AZURE_CLIENT_SECRET'], tenant=os.environ['AZURE_TENANT_ID'])
subscription_id = os.environ['AZURE_SUBSCRIPTION_ID']
resource_client = ResourceManagementClient(credentials, subscription_id)
compute_client = ComputeManagementClient(credentials, subscription_id)
network_client = NetworkManagementClient(credentials, subscription_id)

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
			for filepath in files:
				if filepath.endswith(".png") or filepath.endswith(".jpg"):
					with Image.open(os.path.join(root, filepath)) as img:
						width, height = img.size
						if width == height and width == 256:
							template_image = filepath
							break
			if template_image == None:
				break
			item_name, img_ext = os.path.splitext(template_image)
			item = { "name": item_name, "path": root[len(template_folder)+1:] }
			result.append(item)
	return jsonify(result)

@app.route('/template/<template>/parameters', methods=['GET'])
@admin_required
def parameters(template):
	"""Get template parameters"""
	template_path = os.path.join(os.path.dirname(__file__), template_folder, template, 'template.json')
	with open(template_path, 'r') as template_file_fd:
		template_file = load_json(template_file_fd)
	return jsonify(template_file['parameters'])

@app.route('/template/<template>/icon', methods=['GET'])
def icon(template):
	"""Get template icon"""
	template_path = os.path.join(os.path.dirname(__file__), template_folder, template)
	for root, dirs, files in os.walk(template_path):
		for filepath in files:
			if filepath.endswith(".png"):
				with Image.open(os.path.join(root, filepath)) as img:
					width, height = img.size
					if width == height and width == 256:
						return send_file(os.path.join(template_path, filepath))
	abort(404)

@app.route('/template/<template>/deploy', methods=['POST'])
@admin_required
def deploy(template):
	"""Deploy a new resource group based on a template and some given parameters"""
	parameters = request.get_json()
	group_name = parameters['Resource_Group_Name']
	user_name = parameters['Resource_Group_Admin']
	user_password = parameters['Resource_Group_Password']
	parameters = {k: {'value': v} for k, v in parameters.items() }
	location = os.environ['AZURE_LOCATION']
	resource_group_params = {'location':location}
	resource_group_params.update(tags={'created-by': os.environ['ARM_CREATED_TAG'] })
	resource_client.resource_groups.create_or_update(group_name, resource_group_params)
	template_path = os.path.join(os.path.dirname(__file__), template_folder, template, 'template.json')
	with open(template_path, 'r') as template_file_fd:
		template_file = load_json(template_file_fd)
	deployment_properties = { 'mode': DeploymentMode.incremental, 'template': template_file, 'parameters': parameters }
	deployment_async_operation = resource_client.deployments.create_or_update(group_name, 'azure-sample', deployment_properties)
	deployment_async_operation.wait()
	return "OK"

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
		vm_power = [x.code[x.code.index('/')+1:] for x in instance.statuses if x.code.startswith('PowerState')][0] 
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

if __name__ == '__main__':
	app.run()
