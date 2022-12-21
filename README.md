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
   "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/scripts/win-host-setup.ps1'))"
   ```

1. Restart your command prompt

1. Run Windows Update and reboot when necessary
1. Run the `Ubuntu` application to start WSL and create a username and password for your WSL user
1. Run the following command to configure WSL as an OMG workstation

   ```shell
   $ curl -fsSL https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/scripts/unix-host-setup.sh | bash
   ```

1. Follow the onscreen instructions to finish configuring your WSL installation

## Install & Configure Software (macOS/Linux)

Run the following command in your shell to setup a macOS or Linux host:

```bash
$ curl -fsSL https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/scripts/unix-host-setup.sh | bash
```

## Post-installation (Windows)

We recommend configuring your computer using the [PlayOneMoreGame/dotfiles](https://github.com/PlayOneMoreGame/dotfiles) repository, which configures, among other things, sane defaults for bash across Windows/WSL/Mac/Linux, and allows for running X-Windows (GUI) programs from WSL.

### Windows Issues

If you're endeavoring to change the powershell scripts on Github and it is not working, remember that Powershell performs web-request caching, which you'll need to disable it; for example:

```powershell
iwr https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/scripts/win-software-setup.ps1 -UseBasicParsing -Headers @{ "Pragma"="no-cache"; "Cache-Control"="no-cache"; } | iex
```

(from https://www.reddit.com/r/PowerShell/comments/8qd9sm/invokewebrequest_pulling_stale_data_from_github/e0ialgd/)


# Intune
This collection of scripts are used within Intune packages to handle automated provisioning for @onemoregame.com AAD domain member computers. Any time we change the contents of these scripts we must re-generate the Intune packages containing them and upload the updated versions to Intune.

## Rebuilding Intune packages
Use the `make-intune-<module>` make commands to rebuild intune packages. This will create .intunewin files in the ./intune subdirectory.

## URLs
Intune packages updated via Make can be uploaded at the following Intune endpoints.

intune/PS_lib.intunewin        : https://endpoint.microsoft.com/#blade/Microsoft_Intune_Apps/SettingsMenu/2/appId/fbcf8019-96bc-4a22-8095-468762a8995b
intune/PS_bootstrap.intunewin  : https://endpoint.microsoft.com/#blade/Microsoft_Intune_Apps/SettingsMenu/2/appId/9687a2ba-ae27-40f0-8e4b-efee9ff14032
intune/PS_developer.intunewin  : https://endpoint.microsoft.com/#blade/Microsoft_Intune_Apps/SettingsMenu/2/appId/7c7a8a24-610d-4151-a45b-878d2fcdce3e
intune/PS_programmer.intunewin : https://endpoint.microsoft.com/#blade/Microsoft_Intune_Apps/SettingsMenu/2/appId/bb89067e-a95a-409e-9c11-3cd00accd5a0
