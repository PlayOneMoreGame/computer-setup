# powershell

$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
. "$ScriptDir/../lib/omg.ps1"

# When using git-bash we need to set the HOME directory variable
if ($null -eq [Environment]::GetEnvironmentVariable('HOME')) {
    [Environment]::SetEnvironmentVariable('HOME', $Env:UserProfile, [EnvironmentVariableTarget]::User)
    $env:HOME = $Env:UserProfile
}

# Create user "bin" directory to store tools, and add it to the path
$BinPath = Join-Path -Path $Env:UserProfile -ChildPath "bin"
if (! (Test-Path $BinPath)) {
    New-Item -ItemType Directory -Force -Path $BinPath | Out-Null
}
Add-EnvPath -Path $binPath -Container 'User'

# PowerShellGet requires NuGet provider version '2.8.5.201' or newer to interact
# with NuGet-based repositories.
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Disable memory compression agent; buy more RAM instead.
Disable-MMAgent -mc

# Install Chocolatey
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install -y git
choco install -y dotnet-5.0-sdk

Update-Path

# Add Nuget sources
dotnet nuget add source --name nuget.org https://api.nuget.org/v3/index.json

# Install "scoop" package manager
if (Get-Command -Name "scoop" -ErrorAction SilentlyContinue) {
    scoop update
} else {
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

Update-Path
