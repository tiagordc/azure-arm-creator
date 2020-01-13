import os
import json
from flask import Flask, render_template, send_from_directory, send_file, jsonify, abort, request
from PIL import Image

app = Flask(__name__)
template_folder = os.environ['ARM_TEMPLATE_FOLDER']

@app.route('/static/<path:path>', methods=['GET'])
def static_files(path):
	"""Serve static files from the static folders"""
	return send_from_directory('static', path)

@app.route('/', methods=['GET'])
def index():
	"""Home"""
	return render_template('index.html')

@app.route('/templates', methods=['GET'])
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
def parameters(template):
	"""Get template parameters"""
	template_path = os.path.join(os.path.dirname(__file__), template_folder, template, 'template.json')
	with open(template_path, 'r') as template_file_fd:
		template_file = json.load(template_file_fd)
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
def deploy(template):
	"""Deploy a new resource group based on a template and some given parameters"""
	from azure.common.credentials import ServicePrincipalCredentials
	from azure.mgmt.resource import ResourceManagementClient
	from azure.mgmt.resource.resources.models import DeploymentMode
	parameters = request.get_json()
	group_name = parameters['Resource_Group_Name']
	parameters = {k: {'value': v} for k, v in parameters.items() }
	credentials = ServicePrincipalCredentials(client_id=os.environ['AZURE_CLIENT_ID'], secret=os.environ['AZURE_CLIENT_SECRET'], tenant=os.environ['AZURE_TENANT_ID'])
	subscription_id = os.environ['AZURE_SUBSCRIPTION_ID']
	client = ResourceManagementClient(credentials, subscription_id)
	location = os.environ['AZURE_LOCATION']
	resource_group_params = {'location':location}
	resource_group_params.update(tags={'created-by': os.environ['ARM_CREATED_TAG'] })
	client.resource_groups.create_or_update(group_name, resource_group_params)
	template_path = os.path.join(os.path.dirname(__file__), template_folder, template, 'template.json')
	with open(template_path, 'r') as template_file_fd:
		template_file = json.load(template_file_fd)
	deployment_properties = { 'mode': DeploymentMode.incremental, 'template': template_file, 'parameters': parameters }
	deployment_async_operation = client.deployments.create_or_update(group_name, 'azure-sample', deployment_properties)
	deployment_async_operation.wait()
	return "OK"

if __name__ == '__main__':
	app.run()
	