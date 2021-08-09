
# - Author:
# Levi Wilkerson
# https://github.com/levifrosty

# - CompanyName: 
# LightChange Technologies

# - Name:
# Syxsense Powershell Installation

# - Synopsis:
# Installs Syxsense Agent with site lock.

# - Description:
# Downloads the latest Syxsense installer and installs the agent. If already installed, this will reinstall Syxsense completely.

# - Version: 1.0

# - Help:
# For this script to run, you must edit the $site variable to match the Syxsense site name exactly, found at the section: VARIABLES
#  Examples: $site = '"LightChange Technologies"'
#  Examples: $site = '"Contoso Inc."'
# You must have an internet connection to run this script.
# You must be an administrator.

$site = '"Default Site"'

if ($site -match '"Default Site"') {
  Write-Warning "Please configure `$site variable, then re-run this script"
  Read-Host 'Press enter to exit'
  exit
}

$syxsenseURL = 'https://lightchange.cloudmanagementsuite.com/WebService/api/v1/Downloads/ResponderSetup.msi'

# Admin Check
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning “You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!”
    Read-Host 'Press enter to exit'
    exit
}

# Deletes Syxsense if exists.
if (Test-Path "$env:HOMEDRIVE\`$VCMSTEMP$") {
  get-service * | Where-Object DisplayName -match 'Syxsense' | stop-service -Force -Verbose
  Remove-Item "$env:HOMEDRIVE\`$VCMSTEMP$" -Force -Verbose -Recurse
}


# Temp folder to hold installation file
if (!(test-path $env:temp)) {
  write-host "Path `$env:temp is missing`nCreating temp directory..."
  New-Item -path "$env:temp" -ItemType 'directory'
}

# Download and install
try {
  $installPath = "$env:temp\responersetup.msi"
  Invoke-WebRequest $syxsenseURL -OutFile $installPath -Verbose
  $params = '/i', "$env:temp\responersetup.msi", '/qn', '/log', "$env:temp\syxsenseInstallLog.txt", "SITELOCKNAME=$site"
  Start-Process 'msiexec.exe' -ArgumentList $params -NoNewWindow -Wait -PassThru
}
catch {
  Write-Host 'Please check your internet connection and try again'
}

# Cleanup of installation files and log files.
Remove-Item "$env:temp\responersetup.msi" -Force -Verbose
Remove-Item "$env:temp\syxsenseInstallLog.txt" -Force -Verbose

if (test-path "$env:HOMEDRIVE\`$VCMSTEMP$") {
  get-service * | Where-Object DisplayName -match 'Syxsense' | start-service -Force -Verbose
  Write-Host 'Syxsense succesfully installed!' -Foregroundcolor Green
}
exit