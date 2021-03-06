import os
from PIL import Image

def icon_for_template(template_folder, template):
	"""Get template icon"""
	template_path = os.path.join(os.path.dirname(__file__), template_folder, template)
	for root, dirs, files in os.walk(template_path):
		for filepath in files:
			if filepath.endswith(".png"):
				with Image.open(os.path.join(root, filepath)) as img:
					width, height = img.size
					if width == height and width == 256:
						return os.path.join(template_path, filepath)

def template_name(template_folder, template):
	template_image = icon_for_template(template_folder, template)
	template_image = os.path.basename(template_image)
	item_name, img_ext = os.path.splitext(template_image)
	return item_name
	