# powershell -ExecutionPolicy Unrestricted -File Win10Lock.ps1 -fromUrl "https://...." -zipDownload "https://...." -zipFolder "C:\Custom" -packages "soapui,putty.install" -userName "customer" -userPass "password"

param ([string]$fromUrl, [string]$zipDownload, [string]$zipFolder, [string]$packages, [string]$userName, [string]$userPass)

# Create user
if ($userName) {
	New-LocalUser -Name $userName -Password ($userPass | ConvertTo-SecureString -AsPlainText -Force)
	Add-LocalGroupMember -Group "Remote Desktop Users" -Member $userName
}

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

# Install additional tools
if ($packages) {
	$packages.Split(",")  | ForEach {
		choco install $_
	}
}

# Download Zip File
New-Item -ItemType Directory -Force -Path $zipFolder
$zipPath = $zipFolder + '\_TEMP_.zip'
Invoke-WebRequest $zipDownload -OutFile $zipPath
Expand-Archive -LiteralPath $zipPath -DestinationPath $zipFolder
Remove-Item $zipPath

# Run final script
$scriptFile = $zipFolder + "\PRE_EXECUTE.ps1"
if (Test-Path $scriptFile) {
	&$scriptFile -fromUrl $fromUrl -zipDownload $zipDownload -zipFolder $zipFolder -packages $packages -userName $userName -userPass $userPass
	Remove-Item $scriptFile
}

# Disable "Choose Privacy Settings."
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "DisablePrivacyExperience" -Value 1 -PropertyType Dword -Force

# Disables Windows Feedback Experience
$regkey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "Enabled" -Value 0 -PropertyType Dword -Force

# Stops Cortana from being used as part of your Windows Search Function and Web Search in Start Menu
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

# Stops the Windows Feedback Experience from sending anonymous data
$regkey = "HKCU:\Software\Microsoft\Siuf\Rules"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "PeriodInNanoSeconds" -Value 0 -PropertyType Dword -Force

# Prevents bloatware applications from returning and removes Start Menu suggestions
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

# Preping mixed Reality Portal for removal
$regkey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "FirstRunSucceeded" -Value 0 -PropertyType Dword -Force

# Disables Wi-fi Sense
$regkey = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "Value" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "Value" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AutoConnectAllowedOEM" -Value 0 -PropertyType Dword -Force

# Disables live tiles
$regkey = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "NoTileApplicationNotification" -Value 1 -PropertyType Dword -Force

# Turns off Data Collection via the AllowTelemtry key by changing it to 0
$regkey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AllowTelemetry" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AllowTelemetry" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "AllowTelemetry" -Value 0 -PropertyType Dword -Force

# Disabling Location Tracking
$regkey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "SensorPermissionState" -Value 0 -PropertyType Dword -Force
$regkey = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "Status" -Value 0 -PropertyType Dword -Force

# Disables People icon on Taskbar
$regkey = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "PeopleBand" -Value 0 -PropertyType Dword -Force

# Disables scheduled tasks that are considered unnecessary
Get-ScheduledTask  XblGameSaveTask | Disable-ScheduledTask
Get-ScheduledTask  Consolidator | Disable-ScheduledTask 
Get-ScheduledTask  UsbCeip | Disable-ScheduledTask
Get-ScheduledTask  DmClient | Disable-ScheduledTask
Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask 

# Disabling the Diagnostics Tracking Service
Stop-Service "DiagTrack"
Set-Service "DiagTrack" -StartupType Disabled

# Disable Edge first run
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "PreventFirstRunPage" -Value 1 -PropertyType Dword -Force

# Disable Firewall
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\StandardProfile"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "EnableFirewall" -Value 0 -PropertyType Dword -Force

# Disable Windows Defender
$regkey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
if (!(Test-Path $regkey)) {New-Item -Path $regkey -force}
New-ItemProperty -Path $regkey -Name "DisableAntiSpyware" -Value 1 -PropertyType Dword -Force
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "SecurityHealth" -ErrorAction SilentlyContinue

# Run final script
$scriptFile = $zipFolder + "\POST_EXECUTE.ps1"
if (Test-Path $scriptFile) {
	&$scriptFile -fromUrl $fromUrl -zipDownload $zipDownload -zipFolder $zipFolder -packages $packages -userName $userName -userPass $userPass
	Remove-Item $scriptFile
}
