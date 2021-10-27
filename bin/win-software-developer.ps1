# powershell

# ================================
# Admin permissions required
#=================================

choco install -y dotnet-5.0-sdk
choco install -y git
choco install -y git-credential-winstore
choco install -y git-lfs
choco install -y github-desktop
choco install -y microsoft-windows-terminal

# Install "scoop" package manager
if (Get-Command -Name "scoop" -ErrorAction SilentlyContinue) {
    scoop update
} else {
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# Install github command-line tool
if (scoop list gh 2>&1 | Out-Null) {
    scoop bucket add github-gh "https://github.com/cli/scoop-gh.git"
    scoop install gh
} else {
    scoop update gh
}

# Replacement for unix find
if (scoop list fd 2>&1 | Out-Null) {
    scoop install fd
} else {
    scoop update fd
}

# Python
if (scoop list python 2>&1 | Out-Null) {
    scoop install python
} else {
    scoop update python
}
