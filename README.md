# Azure Resource Creator

Allow your users to create and manage azure resources (based on a set of ARM templates) without any kind of cloud knowledge.

Each template will create a resource group with an admin user and password.

Developed with minimum possible assets to work on an iPad with Pythonista 3.

## Project structure

 * \[ARM_TEMPLATE_FOLDER\]
    * \[Template Folder\]
        * \[Template Name\].png - 256x256 png
        * template.json - ARM template
            * Parameter: "Resource_Group_Name": { "defaultValue": "", "type": "string" }
            * Parameter: "Resource_Group_Admin": { "defaultValue": "", "type": "string" }
            * Parameter: "Resource_Group_Password": { "defaultValue": "", "type": "securestring" }

 * templates
    * admin.html - Template creation page
    * resource.html - Resource group administration page
    
 * .env - environment configuration with [azure authentication](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
 * app.py - API endpoints
 * auth.py - Authentication decorators
 
 ### ARM references

 * [Functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions)
 * [Unique Names](https://www.codeisahighway.com/use-uniquestring-function-to-generate-unique-names-for-resources-in-arm-template/)
 * [SSH Password](https://github.com/Azure/azure-quickstart-templates/blob/master/101-hdinsight-linux-ssh-password/azuredeploy.json)
 * [Secrets](https://devkimchi.com/2019/04/24/6-ways-passing-secrets-to-arm-templates/)
