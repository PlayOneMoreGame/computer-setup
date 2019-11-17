# Computer setup

This public repository contains the scripts necessary to bootstrap a computer to the point where it can download private repositories from Github that perform the rest of the computer setup process.

## Windows

To install, run one of the followings commands:

````cmd
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/setup.ps1'))"
````

````powershell
iwr https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/setup.ps1 -UseBasicParsing | iex
````

### Windows Issues

If you're endeavoring to change `setup.ps1` on Github and it is not working, remember that Powershell performs web-request caching, which you'll need to disable:

````powershell
iwr https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/setup.ps1 -UseBasicParsing -Headers @{ "Pragma"="no-cache"; "Cache-Control"="no-cache"; } | iex
````
(from https://www.reddit.com/r/PowerShell/comments/8qd9sm/invokewebrequest_pulling_stale_data_from_github/e0ialgd/)
