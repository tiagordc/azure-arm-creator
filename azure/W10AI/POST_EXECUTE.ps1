
param ([int]$logLevel = 0, [string]$serviceUrl, [string]$resourceGroup, [string]$vmName, [string]$zipDownload, [string]$zipFolder, [string]$packages, [string]$userName, [string]$userPass)

Write-Output "POST EXECUTE - Add user to local administrators"
Add-LocalGroupMember -Group "Administrators" -Member $userName

Set-Location C:\
Set-Location (Get-ChildItem -Path c:\ -Filter "Python*" -Directory).Name

python -m pip install --upgrade pip

pip.exe install pipenv
pip.exe install jupyter
pip.exe install tensorflow
