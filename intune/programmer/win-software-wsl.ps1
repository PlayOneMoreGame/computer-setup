# powershell

$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
. "$ScriptDir/../lib/omg.ps1"

# ================================
# Admin permissions required
#=================================

# Enable Windows features for Docker/Linux/etc.
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Hyper-V -All
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux
Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName VirtualMachinePlatform

choco install -y wsl2
choco install -y wsl-ubuntu-2004

Update-Path

wsl --update
wsl --set-default-version 2
wsl --shutdown
