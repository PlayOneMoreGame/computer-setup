(New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/intune/bin/win-software-setup.ps1") | Out-File bootstrap.ps1
iex ("./bootstrap.ps1 -WorkingDir C:\omg\ps")
