# Azure Resource Creator

A simple website to create Azure resources (based on hidden ARM templates) that don't require any technical knowledge.

![preview](https://raw.githubusercontent.com/tiagordc/azure-arm-creator/master/static/images/preview1.png)

Use this tool to:
   * Spin up your devops environments and deallocate them when not in use
   * Allow users to create software demos and provide a dedicated portal to magage resources
   * Extend your iPad capabilities

## Setup

Just do the  environment configuration with [azure authentication](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)

 ### ARM references

 * [Functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions)
 * [Unique Names](https://www.codeisahighway.com/use-uniquestring-function-to-generate-unique-names-for-resources-in-arm-template/)
 * [SSH Password](https://github.com/Azure/azure-quickstart-templates/blob/master/101-hdinsight-linux-ssh-password/azuredeploy.json)
 * [Secrets](https://devkimchi.com/2019/04/24/6-ways-passing-secrets-to-arm-templates/)

### Run on Linux

python3 -m venv venv\
source venv/bin/activate\
pip install -r requirements.txt\
export FLASK_APP=application.py\
flask run

### Run in Windows

py -3 -m venv env\
env\scripts\activate\
pip install -r requirements.txt\
SET FLASK_APP=application.py\
flask run

### Run on an iPad

