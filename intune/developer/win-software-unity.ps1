# powershell

$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
. "$ScriptDir/../lib/omg.ps1"

# ================================
# Admin permissions required
#=================================

choco install -y unity-hub

# https://github.com/microsoft/unitysetup.powershell
Install-Module UnitySetup -Force
Install-UnitySetupInstance -Installers (Find-UnitySetupInstaller -Version "2020.3.22f1" -Components "Windows","Windows_IL2CPP")

Update-Path
