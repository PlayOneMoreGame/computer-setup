# Computer setup

This public repository contains the scripts necessary to bootstrap a macOS, Linux, or Windows machine into a One More Game workstation.

## Setup Host (Windows)

Our Windows Desktop PCs come imaged with Win10 Professional. Upon first login using an @onemoregame.com online account, our auto-provisioning processes should kick in and deploy the common components needed for development on OMG projects. The rest of this document

## Setup Host (macOS/Linux)

No additional setup required.

## Install & Configure Software (Windows)

Again, this step is only necessary if auto-provisioning tools are not working or unavailable. This step will setup your Windows machine with some useful development tools to get started.

1. Login to Windows with the desired user
1. Run the software setup script

   ```batch
   "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://3xx.onemoregame.com/win-software-setup.ps1'))"
   ```

1. Restart your command prompt

1. Run Windows Update and reboot when necessary
1. Run the `Ubuntu` application to start WSL and create a username and password for your WSL user
1. Run the following command to configure WSL as an OMG workstation

   ```shell
   $ curl -fsSL https://3xx.onemoregame.com/unix-host-setup.sh | bash
   ```

1. Follow the onscreen instructions to finish configuring your WSL installation

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
