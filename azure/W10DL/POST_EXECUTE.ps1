
param ([int]$logLevel = 0, [string]$serviceUrl, [string]$resourceGroup, [string]$vmName, [string]$zipDownload, [string]$zipFolder, [string]$packages, [string]$userName, [string]$userPass)

Write-Output "POST EXECUTE - Add user to local administrators"
Add-LocalGroupMember -Group "Administrators" -Member $userName

$python = (Get-ChildItem -Path c:\ -Filter "Python*" -Directory).Name

Write-Output "POST EXECUTE - Install packages"
$path = "C:\" + $python + "\Scripts\pip.exe"
& $path install --upgrade pip
& $path install pipenv jupyter tensorflow
& $path install numpy scipy scikit-learn pillow h5py keras

Write-Output "POST EXECUTE - Allow jupyter external access"
$path = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
& $path req -x509 -nodes -days 365 -newkey rsa:1024 -keyout "C:\jupyter.key" -out "C:\jupyter.pem" -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
mkdir "C:\jupyter"
$path = "C:\" + $python + "\python.exe"
$pass = (& $path -c "from notebook.auth import passwd; print(passwd('$userPass'))")
$command = "jupyter notebook --ip=* --no-browser --port 8888 --certfile='C:\jupyter.pem' --keyfile 'C:\jupyter.key' --allow-root --notebook-dir='C:\jupyter' --NotebookApp.allow_origin=* --NotebookApp.password='$pass'"
Set-Content "C:\run jupyter.txt" $command 
