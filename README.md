# Computer setup

This repository is forked from a public repository that contains the setup scripts for a new One More Game employee.  I've modified them to setup my own personal computer while still being able to be a, somewhat, good employee.

## New Desktop PC Setup

Normal One More Game PCs come imaged with a single administrator user (`Jamie`) and need to first be configured before attempting to setup user land in the next section.  We'll skip this step.

1. DON'T DO THIS: Perform the initial setup by running one of the following commands
    ````cmd
    "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/petergiuntoliisdumb/computer-setup/master/bin/host-setup.ps1'))"
    ````

    ````powershell
    iwr https://raw.githubusercontent.com/petergiuntoliisdumb/computer-setup/master/bin/host-setup.ps1 -UseBasicParsing | iex
    ````
1. Reboot the machine

## New Windows User Setup

1. Login to Windows with the desired user
1. Run one of the following commands
    ````cmd
    "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/petergiuntoli/computer-setup/master/bin/setup.ps1'))"
    ````

    ````powershell
    iwr https://raw.githubusercontent.com/petergiuntoli/computer-setup/master/bin/setup.ps1 -UseBasicParsing | iex
    ````

## Post-installation

We recommend configuring your computer using the [petergiuntoli/dotfiles](https://github.com/petergiuntoli/dotfiles) repository, which configures, among other things, sane defaults for bash across Windows/WSL/Mac/Linux, and allows for running X-Windows (GUI) programs from WSL.

### Windows Issues

If you're endeavoring to change `setup.ps1` on Github and it is not working, remember that Powershell performs web-request caching, which you'll need to disable:

````powershell
iwr https://raw.githubusercontent.com/petergiuntoli/computer-setup/master/bin/setup.ps1 -UseBasicParsing -Headers @{ "Pragma"="no-cache"; "Cache-Control"="no-cache"; } | iex
````
(from https://www.reddit.com/r/PowerShell/comments/8qd9sm/invokewebrequest_pulling_stale_data_from_github/e0ialgd/)

### Windows Subsystem for Linux

We use the "Nix" package manager, but it does not work in WSL version 1 because WSL1 filesystem emulation does not work properly (https://github.com/NixOS/nix/issues/1203). The remediations listed in that Github issue do not work (i.e. use-sqlite-wal = false, sandbox = false) nor does setting the Windows "Enable Long Filenames" registry entry, reported as a fix elsewhere.

However, WSL version 2 does work, but the official release date is still in the future as of this writing, so:

1. Subscribe to the Windows Insider Program
    * With your personal Microsoft Account with the [Online Insider Enroll](https://insider.windows.com/en-us/) or
    * In an automated way by performing an [Offline Insider Enroll](https://github.com/whatever127/offlineinsiderenroll)
1. Set your Windows Insider update cycle to the 'Slow Ring'
1. Update Windows
1. Install the [Ubuntu WSL Distribution](https://www.microsoft.com/en-us/p/ubuntu/9nblggh4msv6)
1. Set the default WSL version number `wsl --set-default-version 2`
1. Set the WSL version number for Ubuntu: `wsl --set-version ubuntu 2`

