# powershell

$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
. "$ScriptDir/../lib/omg.ps1"

# ================================
# Admin permissions required
#=================================
choco install -y git-credential-winstore
choco install -y git-lfs
choco install -y github-desktop

# Install github command-line tool
$match = scoop info gh | Select-String -Pattern "Installed\: No"
if ($match -ne $null) {
    scoop bucket add github-gh "https://github.com/cli/scoop-gh.git"
    scoop install gh
} else {
    scoop update gh
}

# Replacement for unix find
$match = scoop info fd | Select-String -Pattern "Installed\: No"
if ($match -ne $null) {
    scoop install fd
} else {
    scoop update fd
}

# Python
$match = scoop info python | Select-String -Pattern "Installed\: No"
if ($match -ne $null) {
    scoop install python
} else {
    scoop update python
}

# prereq for microsoft windows terminal
$archiveUrl = 'https://download.microsoft.com/download/4/7/c/47c6134b-d61f-4024-83bd-b9c9ea951c25/14.0.30035.0-Desktop/Microsoft.VCLibs.x64.14.00.Desktop.appx'
$archiveName = Split-Path -Leaf $archiveUrl
$archivePath = "$env:TEMP\$archiveName"
(New-Object System.Net.WebClient).DownloadFile($archiveUrl, $archivePath)
Add-AppxPackage $archivePath
Remove-Item $archivePath

choco install -y microsoft-windows-terminal

Update-Path
