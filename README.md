# Azure Resource Creator

Allow users to create and manage Azure resources (based on hidden ARM templates) without any kind of cloud knowledge.

Each template will create a resource group in Azure and a management area within this tool protected with a password.

Uses basic authentication using decorators so any other logic can be used instead.

There is no database involved, all properties are stored as resource tags on azure.

Developed with minimum possible assets to work on an iPad to demonstrate the proof of concept.

## Project structure

 * \[ARM_TEMPLATE_FOLDER\] - azure by default
    * \[Template Folder\] - any name to store template files
    
        * \[Template Name\].png - 256x256 png file that also defines the name to display on the list
        
        * template.json - ARM template file with at least these parameters:
            * "Resource_Group_Name": { "defaultValue": "", "type": "string" }
            * "Resource_Group_Admin": { "defaultValue": "", "type": "string" }
            * "Resource_Group_Password": { "defaultValue": "", "type": "securestring" }

 * templates
    * admin.html - Template creation page
    * resource.html - Resource group administration page

 * automation - PowerShell and bash scripts to run as [CustomScriptExtension](https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-windows)

 * .env - environment configuration with [azure authentication](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
 * app.py - API endpoints
 * auth.py - Authentication decorators
 * utils.py - Generic utilities

 ### ARM references

 * [Functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions)
 * [Unique Names](https://www.codeisahighway.com/use-uniquestring-function-to-generate-unique-names-for-resources-in-arm-template/)
 * [SSH Password](https://github.com/Azure/azure-quickstart-templates/blob/master/101-hdinsight-linux-ssh-password/azuredeploy.json)
 * [Secrets](https://devkimchi.com/2019/04/24/6-ways-passing-secrets-to-arm-templates/)
