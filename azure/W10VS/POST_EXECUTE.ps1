
param ([int]$logLevel = 0, [string]$serviceUrl, [string]$resourceGroup, [string]$vmName, [string]$zipDownload, [string]$zipFolder, [string]$packages, [string]$userName, [string]$userPass)

Write-Output "POST EXECUTE - Add user to local administrators"
Add-LocalGroupMember -Group "Administrators" -Member $userName

# Windows 10 Developer Mode
$regkey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1

# Install Linux Subsystem
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux

$wshshell = New-Object -ComObject WScript.Shell

if (Test-Path "C:\ProgramData\chocolatey\bin\FlaUInspect.exe") {
    $lnk = $wshshell.CreateShortcut("C:\Users\Public\Desktop\FlaUInspect.lnk")
    $lnk.TargetPath = "C:\ProgramData\chocolatey\bin\FlaUInspect.exe"
    $lnk.Save()
}

# Docker https://stackoverflow.com/a/50099965
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -Verbose
bcdedit /set hypervisorlaunchtype Auto
