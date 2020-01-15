# powershell

function Add-EnvPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )

    if ($Container -ne 'Session') {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User    = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
        if ($persistedPaths -notcontains $Path) {
            $persistedPaths = $persistedPaths + $Path | Where-Object { $_ }
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths -join ';', $containerType)
        }
    }

    $envPaths = $env:Path -split ';'
    if ($envPaths -notcontains $Path) {
        $envPaths = $envPaths + $Path | Where-Object { $_ }
        $env:Path = $envPaths -join ';'
    }
}

function Enable-VcXsrv-Hosts-File-Changes () {
    $HostsFile = "c:\Program Files\VcXsrv\X0.hosts"
    $acl = Get-Acl $HostsFile
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
        "FullControl",
        "Allow")
    $acl.AddAccessRule($AccessRule)
    $acl | Set-Acl $HostsFile
}

# Elevate script to run as administrator
$WindowsId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($WindowsId)
if ($WindowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {

    ################################################
    # This code runs with administrative permissions
    ################################################

    # Install Chocolatey
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

    # Install required tools
    choco install -y 7zip
    choco install -y ConEmu
    choco install -y Firefox
    choco install -y git
    choco install -y git-credential-winstore
    choco install -y golang
    choco install -y GoogleChrome
    choco install -y gow
    choco install -y growl
    choco install -y keybase
    choco install -y nircmd
    choco install -y notepad2
    choco install -y ripgrep
    choco install -y shellcheck
    choco install -y sysinternals
    choco install -y unity-hub
    choco install -y vcxsrv
    choco install -y vscode
    choco install -y winmerge

    # Windows Subsystem for Linux version 2 (WSL2) connects to VcXSrv
    # via a RFC 1918 IP address (i.e. 172.16/12 or 192.168/16) instead
    # of a local loopback address like WSL1, and so our script will
    # need to overwrite the VcXSrv X0.hosts file in order to store that
    # IP address in the file to enable connections. Grant this user
    # permission to modify that file, which otherwise would require
    # administrative permissions.
    Enable-VcXsrv-Hosts-File-Changes

    # Disable memory compression agent; buy more RAM instead.
    Disable-MMAgent -mc

    # Enable Windows features for Docker/Linux/etc.
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName VirtualMachinePlatform
}
else {
    # Re-run this script with administrative permissions. Since the script may have been
    # run by piping (i.e. "iwr $Url | iex") we re-download the script from Github to run it.
    # Man, making this work was, as is typical with Powershell, a total pain.
    if ($Null -eq $MyInvocation.MyCommand.Path) {
        Write-Host "Download and run from Github"
        Start-Process powershell.exe -Wait -Verb RunAs -ArgumentList (
            # If you're having trouble debugging because the window closes, add "-NoExit" below
            "-NoProfile -ExecutionPolicy Bypass -Command iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/setup.ps1'))"
        );
    }
    else {
        Write-Host "Run script locally"
        Start-Process powershell.exe -Wait -Verb RunAs -ArgumentList (
            # If you're having trouble debugging because the window closes, add "-NoExit" below
            "-NoProfile -ExecutionPolicy Bypass -Command iex $($MyInvocation.MyCommand.Path)"
        )
    }

    ################################################
    # This code runs with User permissions
    ################################################

    # Start growl
    & "C:\Program Files (x86)\Growl for Windows\Growl.exe"

    # Register OMG application and message types with Growl
    & "C:\Program Files (x86)\Growl for Windows\growlnotify.com" /r:Debug, Info, Warn, Error, F atal /a:OMG "Register OMG"

    # When using git-bash we need to set the HOME directory variable
    if ($null -eq [Environment]::GetEnvironmentVariable('HOME')) {
        [Environment]::SetEnvironmentVariable('HOME', $Env:UserProfile, [EnvironmentVariableTarget]::User)
    }

    # Create user "bin" directory to store tools, and add it to the path
    $BinPath = Join-Path -Path $Env:UserProfile -ChildPath "bin"
    if (! (Test-Path $BinPath)) {
        New-Item -ItemType Directory -Force -Path $BinPath | Out-Null
    }
    Add-EnvPath -Path $binPath -Container 'User'
}
