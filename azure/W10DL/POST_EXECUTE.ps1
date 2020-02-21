
param ([int]$logLevel = 0, [string]$serviceUrl, [string]$resourceGroup, [string]$vmName, [string]$zipDownload, [string]$zipFolder, [string]$packages, [string]$userName, [string]$userPass)

Write-Output "POST EXECUTE - Add user to local administrators"
Add-LocalGroupMember -Group "Administrators" -Member $userName

Write-Output "POST EXECUTE - Python 3.7"
choco install python --version=3.7.4

Write-Output "POST EXECUTE - PyCharm"
choco install pycharm-community

Write-Output "POST EXECUTE - OpenSSL"
choco install openssl

$python = (Get-ChildItem -Path c:\ -Filter "Python*" -Directory).Name

$path = "C:\" + $python + "\Scripts\pip.exe"
& $path install --upgrade pip
& $path install pipenv jupyter tensorflow
& $path install numpy scipy scikit-learn pillow h5py keras

# TODO: make jupyter available to the public
# https://medium.com/@GuruAtWork/jupyter-notebook-adding-certificates-for-ease-of-use-447f476b9112
# https://jupyter-notebook.readthedocs.io/en/stable/public_server.html
& "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" req -x509 -nodes -days 365 -newkey rsa:1024 -keyout "C:\jupyter.key" -out "C:\jupyter.pem" -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
# jupyter notebook --ip=* --no-browser --port 8888 --certfile="C:\mycert.pem" --keyfile "C:\mykey.key" --NotebookApp.allow_origin=*
