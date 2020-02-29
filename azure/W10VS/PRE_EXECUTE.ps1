
param ([int]$logLevel = 0, [string]$serviceUrl, [string]$resourceGroup, [string]$vmName, [string]$zipDownload, [string]$zipFolder, [string]$packages, [string]$userName, [string]$userPass)

Write-Output "PRE EXECUTE - Disable Firewall"
#Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Get-NetFirewallProfile
