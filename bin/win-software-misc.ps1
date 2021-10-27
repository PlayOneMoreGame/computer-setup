# powershell

# ================================
# Admin permissions required
#=================================

# Add Nuget sources
dotnet nuget add source --name nuget.org https://api.nuget.org/v3/index.json

# PowerShellGet requires NuGet provider version '2.8.5.201' or newer to interact
# with NuGet-based repositories.
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Disable memory compression agent; buy more RAM instead.
Disable-MMAgent -mc

# Install Chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install required tools
choco install -y 1password
choco install -y 7zip
choco install -y discord
choco install -y Firefox
choco install -y GoogleChrome
choco install -y notepad2
choco install -y office365business
choco install -y slack
choco install -y steam
choco install -y sysinternals
choco install -y wireguard
choco install -y zoom
