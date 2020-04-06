# Computer setup

This public repository contains the scripts necessary to bootstrap a macOS, Linux, or Windows machine into a One More Game workstation.

## Setup Host (Windows)

Our Windows Desktop PCs come imaged with a single administrator user and need to first be configured before attempting to setup user land in the next section. This step will create a user account, enable the Windows Administrator account, and setup the computer name.

1. Perform the initial setup by running one of the following commands

    ```batch
    "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/win-host-setup.ps1'))"
    ````

1. Reboot the machine

## Setup Host (macOS/Linux)

No additional setup required.

## Install & Configure Software (Windows)

This step will setup your Windows machine with some useful development tools to get started.

1. Login to Windows with the desired user
1. Run the software setup script

    ```batch
    "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/win-software-setup.ps1'))"
    ```

1. Configure Windows

    ```batch
    mkdir "%USERPROFILE%\code" 2>NUL
    cd /d "%USERPROFILE%\code\computer-setup"
    git clone https://github.com/PlayOneMoreGame/computer-setup.git "%USERPROFILE%\code\computer-setup" "%USERPROFILE%\code\computer-setup\lib\Win10-Setup\Default.cmd"
    ```

## Install & Configure Software (macOS/Linux)

Run the following command in your shell to setup a macOS or Linux host:

```bash
$ curl -fsSL https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/unix-host-setup | bash
```

## Post-installation (Windows)

We recommend configuring your computer using the [PlayOneMoreGame/dotfiles](https://github.com/PlayOneMoreGame/dotfiles) repository, which configures, among other things, sane defaults for bash across Windows/WSL/Mac/Linux, and allows for running X-Windows (GUI) programs from WSL.

### Windows Issues

If you're endeavoring to change the powershell scripts on Github and it is not working, remember that Powershell performs web-request caching, which you'll need to disable it; for example:

```powershell
iwr https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/win-software-setup.ps1 -UseBasicParsing -Headers @{ "Pragma"="no-cache"; "Cache-Control"="no-cache"; } | iex
```

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
