param ([int]$logLevel = 0, [string]$serviceUrl, [string]$resourceGroup, [string]$vmName, [string]$zipDownload, [string]$zipFolder, [string]$packages, [string]$userName, [string]$userPass)

Write-Output "POST EXECUTE - Add user to local administrators"
Add-LocalGroupMember -Group "Administrators" -Member $userName

choco install python --version=3.7.4
choco install pycharm-community
choco install openssl

$python = (Get-ChildItem -Path c:\ -Filter "Python*" -Directory).Name

$env:Path += ";C:\$python\Scripts" 

Write-Output "POST EXECUTE - Install packages"
$path = "C:\" + $python + "\Scripts\pip.exe"
& $path install --upgrade pip
& $path install pipenv jupyter tensorflow numpy scipy scikit-learn pillow h5py keras matplotlib tensorflow_hub

Write-Output "POST EXECUTE - Get Samples"
mkdir "C:\Notebooks"
$path = "C:\Program Files\Git\bin\git.exe"
& $path clone "https://github.com/tiagordc/ai-tutorials.git" "C:\Notebooks"

Write-Output "POST EXECUTE - Allow jupyter external access"
$path = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
& $path req -x509 -nodes -days 365 -newkey rsa:1024 -keyout "C:\jupyter.key" -out "C:\jupyter.pem" -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
$path = "C:\$python\python.exe"
$pass = (& $path -c "from notebook.auth import passwd; print(passwd('$userPass'))")
$command = @"
@echo off
call jupyter notebook --ip=* --no-browser --port 8888 --certfile='C:\jupyter.pem' --keyfile 'C:\jupyter.key' --allow-root --notebook-dir='C:\\Notebooks' --NotebookApp.allow_origin=* --NotebookApp.password='$pass'
pause
"@
Set-Content "C:\jupyter.bat" $command

Write-Output "POST EXECUTE - Create Jupyter Desktop Shortcut"
$wshshell = New-Object -ComObject WScript.Shell
$lnk = $wshshell.CreateShortcut("C:\Users\Public\Desktop\Jupyter.lnk")
$lnk.TargetPath = "C:\jupyter.bat"
$lnk.Save()
$bytes = [System.IO.File]::ReadAllBytes("C:\Users\Public\Desktop\Jupyter.lnk")
$bytes[0x15] = $bytes[0x15] -bor 0x20 #https://stackoverflow.com/questions/28997799/how-to-create-a-run-as-administrator-shortcut-using-powershell
[System.IO.File]::WriteAllBytes("C:\Users\Public\Desktop\Jupyter.lnk", $bytes)
