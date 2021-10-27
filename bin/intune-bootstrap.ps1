$script = (New-Object System.Net.WebClient).DownloadString("https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/intune/bin/win-software-setup.ps1")
iex ("$script -WorkingDir C:\omg\ps")
