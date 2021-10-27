# powershell

# ================================
# Admin permissions required
#=================================

choco install -y unity-hub

# https://github.com/microsoft/unitysetup.powershell
Install-Module UnitySetup -Force
Install-UnitySetupInstance -Installers (Find-UnitySetupInstaller -Version "2020.3.16f1" -Components "Windows","Windows_IL2CPP")
