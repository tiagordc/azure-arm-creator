# powershell -ExecutionPolicy Unrestricted -File Win10Lock.ps1 -log 1 -fromUrl "https://...." -resourceGroup "" -zipDownload "https://...." -zipFolder "C:\Custom" -packages "soapui,putty.install" -userName "customer" -userPass "password"

param ([int]$log = 0, [string]$fromUrl, [string]$resourceGroup, [string]$zipDownload, [string]$zipFolder, [string]$packages, [string]$userName, [string]$userPass)

New-Item -ItemType Directory -Force -Path $zipFolder

if ($log -eq 1) {
	$ErrorActionPreference="SilentlyContinue"
	Stop-Transcript | out-null
	$ErrorActionPreference = "Continue"
	Start-Transcript -path ($zipFolder + "\LOG.txt") -append
}

# Download Zip File
Write-Output "DOWNLOAD - Start"
$zipPath = $zipFolder + '\_TEMP_.zip'
Invoke-WebRequest $zipDownload -OutFile $zipPath
Expand-Archive -LiteralPath $zipPath -DestinationPath $zipFolder
Remove-Item $zipPath

# Run initial script
$scriptFile = $zipFolder + "\PRE_EXECUTE.ps1"
if (Test-Path $scriptFile) {
	Write-Output "PRE_EXECUTE - Start"
	&$scriptFile -fromUrl $fromUrl -resourceGroup $resourceGroup -zipDownload $zipDownload -zipFolder $zipFolder -packages $packages -userName $userName -userPass $userPass
	Write-Output "PRE_EXECUTE - Done"
	Remove-Item $scriptFile
} else {
	Write-Output "PRE_EXECUTE - Missing"
}

# Install Chocolatey
Write-Output "CHOCOLATEY - Start"
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation
choco install sysinternals

# Create user
if ($userName) {
	Write-Output "USER - Start"
	New-LocalUser -Name $userName -Password ($userPass | ConvertTo-SecureString -AsPlainText -Force)
	Add-LocalGroupMember -Group "Remote Desktop Users" -Member $userName
	psexec -h -accepteula -u $userName -p $userPass cmd /c echo
}
else {
	Write-Output "USER - Missing"
}

# Install additional tools
Write-Output "CHOCOLATEY - Packages"
if ($packages) {
	$packages.Split(",")  | ForEach {
		choco install $_
	}
}

# Windows 10 Lockdown

Write-Output "LOCKDOWN - Choose Privacy Settings"
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "DisablePrivacyExperience" -Value 1 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Disables Windows Feedback Experience"
$regkey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "Enabled" -Value 0 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Stop Cortana"
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AllowCortana" -Value 0 -PropertyType Dword -Force
New-ItemProperty -Path $regkey -Name "BingSearchEnabled" -Value 0 -PropertyType Dword -Force
New-ItemProperty -Path $regkey -Name "DisableWebSearch" -Value 1 -PropertyType Dword -Force
$regkey = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AcceptedPrivacyPolicy" -Value 0 -PropertyType Dword -Force
$regkey = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "RestrictImplicitTextCollection" -Value 1 -PropertyType Dword -Force
New-ItemProperty -Path $regkey -Name "RestrictImplicitInkCollection" -Value 1 -PropertyType Dword -Force
$regkey = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "HarvestContacts" -Value 0 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Stops the Windows Feedback Experience"
$regkey = "HKCU:\Software\Microsoft\Siuf\Rules"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "PeriodInNanoSeconds" -Value 0 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Start Menu suggestions"
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "DisableWindowsConsumerFeatures" -Value 1 -PropertyType Dword -Force
$regkey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "ContentDeliveryAllowed" -Value 0 -PropertyType Dword -Force
New-ItemProperty -Path $regkey -Name "OemPreInstalledAppsEnabled" -Value 0 -PropertyType Dword -Force
New-ItemProperty -Path $regkey -Name "PreInstalledAppsEnabled" -Value 0 -PropertyType Dword -Force
New-ItemProperty -Path $regkey -Name "PreInstalledAppsEverEnabled" -Value 0 -PropertyType Dword -Force
New-ItemProperty -Path $regkey -Name "SilentInstalledAppsEnabled" -Value 0 -PropertyType Dword -Force
New-ItemProperty -Path $regkey -Name "SystemPaneSuggestionsEnabled" -Value 0 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Reality Portal"
$regkey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "FirstRunSucceeded" -Value 0 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Wi-fi Sense"
$regkey = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "Value" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "Value" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AutoConnectAllowedOEM" -Value 0 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Disables live tiles"
$regkey = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "NoTileApplicationNotification" -Value 1 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Turns off Data Collection"
$regkey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AllowTelemetry" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AllowTelemetry" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AllowTelemetry" -Value 0 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Disabling Location Tracking"
$regkey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "SensorPermissionState" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "Status" -Value 0 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Disables People icon on Taskbar"
$regkey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "PeopleBand" -Value 0 -PropertyType Dword -Force

Write-Output "LOCKDOWN - Disables scheduled tasks"
Get-ScheduledTask  XblGameSaveTask | Disable-ScheduledTask
Get-ScheduledTask  Consolidator | Disable-ScheduledTask 
Get-ScheduledTask  UsbCeip | Disable-ScheduledTask
Get-ScheduledTask  DmClient | Disable-ScheduledTask
Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask 

Write-Output "LOCKDOWN - Disabling the Diagnostics Tracking Service"
Stop-Service "DiagTrack"
Set-Service "DiagTrack" -StartupType Disabled

Write-Output "LOCKDOWN - Disable Edge first run"
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -ItemType Directory -force}
New-ItemProperty -Path $regkey -Name "PreventFirstRunPage" -PropertyType Dword -Value 1 -Force

Write-Output "LOCKDOWN - Disable Firewall"
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "EnableFirewall" -Value 0 -PropertyType Dword -Force

# Run final script
$scriptFile = $zipFolder + "\POST_EXECUTE.ps1"
if (Test-Path $scriptFile) {
	Write-Output "POST_EXECUTE - Start"
	&$scriptFile -fromUrl $fromUrl -resourceGroup $resourceGroup -zipDownload $zipDownload -zipFolder $zipFolder -packages $packages -userName $userName -userPass $userPass
	Write-Output "POST_EXECUTE - Done"
	Remove-Item $scriptFile
}
else {
	Write-Output "POST_EXECUTE - Missing"
}

if ($log -eq 1) {
	Stop-Transcript
}