# Azure Resource Creator

Allow your users to create and manage azure resources (based on a set of ARM templates) without any kind of cloud knowledge.

Developed with minimum possible assets to work on an iPad with Pythonista 3.

## Folder structure

 * azure
    * \[Template Folder\]
        * \[Template Name\].png - 256x256 png
        * template.json - ARM template
            * First parameter must be: "Resource_Group_Name": { "defaultValue": "", "type": "String" }

## Architecture

 * .env - environment configuration
 * app.py - Flask API endpoints
 * \/templates\/index.html - Framework7 formatted template
 * \/static\/app.js - Framework7 application
 
 ### ARM references

[Unique Names](https://www.codeisahighway.com/use-uniquestring-function-to-generate-unique-names-for-resources-in-arm-template/)

[SSH Password](https://github.com/Azure/azure-quickstart-templates/blob/master/101-hdinsight-linux-ssh-password/azuredeploy.json)
