
param ([int]$logLevel = 0, [string]$serviceUrl, [string]$resourceGroup, [string]$vmName, [string]$zipDownload, [string]$zipFolder, [string]$packages, [string]$userName, [string]$userPass)

Write-Output "POST EXECUTE - Add user to local administrators"
Add-LocalGroupMember -Group "Administrators" -Member $userName

choco install python --version=3.7.4
choco install pycharm-community

$python = (Get-ChildItem -Path c:\ -Filter "Python*" -Directory).Name
Write-Output $python

$path = "C:\" + $python + "\Scripts\pip.exe"
& $path install --upgrade pip
& $path install pipenv jupyter tensorflow
& $path install numpy scipy scikit-learn pillow h5py keras

$path = "C:\" + $python + "\Scripts\jupyter.exe"
& $path notebook --generate-config
