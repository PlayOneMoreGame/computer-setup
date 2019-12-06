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

If you're planning on using Windows Subsystem for Linux (WSL), and you desire to run X-Windows applications, you'll want to copy `./files/vcxsrv-setup` into your WSL drive and link it to your shell configuration:

````
    # If this shell is WSL then configure VcXSrv
    if [[ $(uname -r) =~ "icrosoft" ]]; then
        source $HOME/bin/vcxsrv-setup
    fi
````

### Windows Issues

If you're endeavoring to change `setup.ps1` on Github and it is not working, remember that Powershell performs web-request caching, which you'll need to disable:

````powershell
iwr https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/setup.ps1 -UseBasicParsing -Headers @{ "Pragma"="no-cache"; "Cache-Control"="no-cache"; } | iex
````
(from https://www.reddit.com/r/PowerShell/comments/8qd9sm/invokewebrequest_pulling_stale_data_from_github/e0ialgd/)

### Windows Subsystem for Linux

We use the "Nix" package manager, but it does not work in WSL version 1 because WSL1 filesystem emulation does not work properly (https://github.com/NixOS/nix/issues/1203). The remediations listed in that Github issue do not work (i.e. use-sqlite-wal = false, sandbox = false) nor does setting the Windows "Enable Long Filenames" registry entry, reported as a fix elsewhere.

However, WSL version 2 does work, but the official release date is still in the future as of this writing, so:

1. Subscribe to the Windows Insider Program
2. Get on the Fast Ring
3. Update Windows
4. Install WSL
5. Set the version number: `wsl --set-default <IMAGE-NAME> 2`

# Running GUI applications in WSL

If you want to run GUI applications (e.g. "meld", a visual diff application) from within WSL2, you'll need to run an X-Windows server like VcXSrv on Windows to accept display commands, which is installed by the `./bin/setup.ps1` script in this repository. The easy way to run VcXSrv is by disabling access control, but that means any rando on the Internet can find a way to exploit your X-Windows, so don't do that.

Instead, run the `./bin/vcxsrv-setup` script from a WSL command-prompt to configure VcXSrv to run on login with the correct security settings, and to configure a secret token shared between WSL GUI applications and VcXSrv via the `$HOME/.Xauthority` file.

Then, update your `.bashrc` file to include the following:
````
export DISPLAY="$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}'):0"
````
