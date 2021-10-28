# powershell

$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
. "$ScriptDir/../lib/omg.ps1"

# ================================
# Admin permissions required
#=================================
choco install -y 1password
choco install -y 7zip
choco install -y discord
choco install -y Firefox
choco install -y GoogleChrome
choco install -y notepad2
choco install -y slack
choco install -y steam
choco install -y sysinternals
choco install -y wireguard
choco install -y zoom

Update-Path
