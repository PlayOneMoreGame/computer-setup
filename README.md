# Computer setup

This public repository contains the scripts necessary to bootstrap a macOS, Linux, or Windows machine into a One More Game workstation.

## Setup Host (Windows)

Our Windows Desktop PCs come imaged with a single administrator user and need to first be configured before attempting to setup user land in the next section. This step will create a user account, enable the Windows Administrator account, and setup the computer name.

1. Perform the initial setup by running automated host setup script

   ```batch
   "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://3xx.onemoregame.com/win-host-setup.ps1'))"
   ```

1. Reboot the machine

## Setup Host (macOS/Linux)

No additional setup required.

## Install & Configure Software (Windows)

This step will setup your Windows machine with some useful development tools to get started.

1. Login to Windows with the desired user
1. Run the software setup script

   ```batch
   "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://3xx.onemoregame.com/win-software-setup.ps1'))"
   ```

1. Configure Windows

   ```batch
   mkdir "%USERPROFILE%\code" 2>NUL
   git clone https://github.com/PlayOneMoreGame/computer-setup.git "%USERPROFILE%\code\computer-setup"
   "%USERPROFILE%\code\computer-setup\lib\Win10-Setup\Default.cmd"
   ```

1. Subscribe to the Windows Insider Program
   - With your personal Microsoft Account with the [Online Insider Enroll](https://insider.windows.com/en-us/) or
   - In an automated way by performing an [Offline Insider Enroll](https://github.com/whatever127/offlineinsiderenroll)
1. Set your Windows Insider update cycle to the 'Slow Ring'
1. Run Windows Update and reboot when necessary
1. Install the [Ubuntu WSL Distribution](https://www.microsoft.com/en-us/p/ubuntu/9nblggh4msv6)
1. Set the default WSL version number `wsl --set-default-version 2`
1. Set the WSL version number for Ubuntu: `wsl --set-version ubuntu 2`
1. Run the `Ubuntu` application to start WSL and create a username and password for your WSL user
1. Run the following command to configure WSL as an OMG workstation

   ```shell
   $ curl -fsSL https://3xx.onemoregame.com/unix-host-setup.sh | bash
   ```

1. Follow the onscreen instructions to finish configuring your WSL installation

> WSL Version 2 is [required to use the `Nix` package manager](https://github.com/NixOS/nix/issues/1203). WSL has not had an official release so we must be on the Windows Insider Program.

## Install & Configure Software (macOS/Linux)

Run the following command in your shell to setup a macOS or Linux host:

```bash
$ curl -fsSL https://3xx.onemoregame.com/unix-host-setup.sh | bash
```

## Post-installation (Windows)

We recommend configuring your computer using the [PlayOneMoreGame/dotfiles](https://github.com/PlayOneMoreGame/dotfiles) repository, which configures, among other things, sane defaults for bash across Windows/WSL/Mac/Linux, and allows for running X-Windows (GUI) programs from WSL.

### Windows Issues

If you're endeavoring to change the powershell scripts on Github and it is not working, remember that Powershell performs web-request caching, which you'll need to disable it; for example:

```powershell
iwr https://3xx.onemoregame.com/win-software-setup.ps1 -UseBasicParsing -Headers @{ "Pragma"="no-cache"; "Cache-Control"="no-cache"; } | iex
```

(from https://www.reddit.com/r/PowerShell/comments/8qd9sm/invokewebrequest_pulling_stale_data_from_github/e0ialgd/)
