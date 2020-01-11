import os
from flask import Flask, render_template, send_from_directory, jsonify, abort
from PIL import Image

app = Flask(__name__)
template_folder = 'azure'

@app.route('/static/<path:path>')
def static_files(path):
	return send_from_directory('static', path)

@app.route('/')
def index():
	return render_template('index.html')

@app.route('/templates')
def templates():
	result = []
	for root, dirs, files in os.walk(template_folder):
		if root.startswith(template_folder + '\\') and "template.json" in files:
			template_image = None
			for filepath in files:
				if filepath.endswith(".png") or filepath.endswith(".jpg"):
					with Image.open(root + '\\' + filepath) as img:
						width, height = img.size
						if width == height and width == 256:
							template_image = filepath
							break
			if template_image == None:
				break
			item_name, img_ext = os.path.splitext(template_image)
			item = { "name": item_name, "path": root[len(template_folder)+1:], "image": template_image }
			result.append(item)
	return jsonify(result)

@app.route('/templates/<path:path>')
def template(path):
	return send_from_directory(template_folder, path)

if __name__ == '__main__':
	app.run()
	
