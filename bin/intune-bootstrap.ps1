$cli = New-Object System.Net.WebClient
$cli.CachePolicy = New-Object System.Net.Cache.RequestCachePolicy -ArgumentList NoCacheNoStore 

$cli.DownloadString("https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/intune/bin/win-software-setup.ps1") | Out-File bootstrap.ps1
./bootstrap.ps1 -WorkingDir C:\omg\ps
