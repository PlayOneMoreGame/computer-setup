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
    choco install -y ag
    choco install -y ConEmu
    choco install -y Firefox
    choco install -y forticlientvpn
    choco install -y git
    choco install -y git-credential-winstore
    choco install -y git-lfs
    choco install -y golang
    choco install -y GoogleChrome
    choco install -y ilspy
    choco install -y growl
    choco install -y keybase
    choco install -y microsoft-windows-terminal
    choco install -y nircmd
    choco install -y notepad2
    choco install -y ripgrep
    choco install -y shellcheck
    choco install -y sysinternals
    choco install -y unity-hub
    choco install -y vscode
    choco install -y winmerge
    choco install -y wireguard --pre

    # Disable memory compression agent; buy more RAM instead.
    Disable-MMAgent -mc

    # Enable Windows features for Docker/Linux/etc.
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName Microsoft-Windows-Subsystem-Linux
    Enable-WindowsOptionalFeature -Online -NoRestart -FeatureName VirtualMachinePlatform

    # Associate "Markdown" files with VSCode to make it easy for developers to open them
    cmd.exe /c assoc .md=VSCodeSourceFile
}
else {
    # Re-run this script with administrative permissions. Since the script may have been
    # run by piping (i.e. "iwr $Url | iex") we re-download the script from Github to run it.
    # Man, making this work was, as is typical with Powershell, a total pain.
    if ($Null -eq $MyInvocation.MyCommand.Path) {
        Write-Host "Download and run from Github"
        Start-Process powershell.exe -Wait -Verb RunAs -ArgumentList (
            # If you're having trouble debugging because the window closes, add "-NoExit" below
            "-NoProfile -ExecutionPolicy Bypass -Command iex ((New-Object System.Net.WebClient).DownloadString('https://3xx.onemoregame.com/win-software-setup.ps1'))"
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

    # When using git-bash we need to set the HOME directory variable
    if ($null -eq [Environment]::GetEnvironmentVariable('HOME')) {
        [Environment]::SetEnvironmentVariable('HOME', $Env:UserProfile, [EnvironmentVariableTarget]::User)
    }

    # Start growl
    & "C:\Program Files (x86)\Growl for Windows\Growl.exe"

    # Register OMG application and message types with Growl; ignore errors
    & "C:\Program Files (x86)\Growl for Windows\growlnotify.com" "/r:Debug,Info,Warn,Error,Fatal" "/a:OMG" "Register OMG" 2>&1 | Out-Null

    # Create user "bin" directory to store tools, and add it to the path
    $BinPath = Join-Path -Path $Env:UserProfile -ChildPath "bin"
    if (! (Test-Path $BinPath)) {
        New-Item -ItemType Directory -Force -Path $BinPath | Out-Null
    }
    Add-EnvPath -Path $binPath -Container 'User'

    # Install "scoop" package manager
    try {
        if (Get-Command -Name "scoop") {
            scoop update
        }
    } catch {
        Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
    }

    # Install github command-line tool
    try {
        if (Get-Command -Name "gh") {
            scoop update gh
        }
    } catch {
        scoop bucket add github-gh "https://github.com/cli/scoop-gh.git"
        scoop install gh
    }
}
