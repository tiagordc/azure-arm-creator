# Azure Resource Creator

Allow your users to create and manage azure resources (based on a set of ARM templates) without any kind of cloud knowledge.

Developed with minimum possible assets to work on an iPad with Pythonista 3.

## Folder structure

 * azure
    * \[Template Folder\]
        * \[Template Name\].png - 256x256 png
        * template.json - ARM template

## Configuration

 * azure
    * config.json

```json
{

}
```

## Design

 * app.py - Flask API
 * \/templates\/index.html - Framework7 formatted template
 * \/static\/app.js - Framework7 application
 
