# Azure Sandbox Creator

A simple tool to create Azure resources (based on ARM templates) that may or may not require technical knowledge (shell, json, etc.)

![preview](https://raw.githubusercontent.com/tiagordc/azure-arm-creator/master/static/images/preview1.png)

Possible use cases:
   * Spin up your devops environments from your smartphone and deallocate them when not in use
   * Create software demos and provide a dedicated portal to magage those resources (VMs and NSGs)
   * Extend your iPad capabilities with a cheap VM on the cloud

The examples provided are just a subset of templates I needed at some point in time for a specific reason. Don't use them as an architecture reference.

## Setup

Start by doing the environment configuration with the required [authentication data](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)

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

## References

* [Functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions)
* [Unique Names](https://www.codeisahighway.com/use-uniquestring-function-to-generate-unique-names-for-resources-in-arm-template/)
* [SSH Password](https://github.com/Azure/azure-quickstart-templates/blob/master/101-hdinsight-linux-ssh-password/azuredeploy.json)
* [Secrets](https://devkimchi.com/2019/04/24/6-ways-passing-secrets-to-arm-templates/)

## TODO

* Select inputs
* Comment lines on templates
* Show error messages
* Remove "priority": "Spot" if the deployment failed with InvalidTemplateDeployment for that reason (and evictionPolicy)
