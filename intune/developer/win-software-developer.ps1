# powershell

$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
. "$ScriptDir/../lib/omg.ps1"

# ================================
# Admin permissions required
#=================================
choco install -y git-credential-winstore
choco install -y git-lfs
choco install -y github-desktop
choco install -y microsoft-windows-terminal

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

Update-Path
