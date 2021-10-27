# powershell

param(
    [switch]$IsDeveloper  = $false,
    [switch]$IsProgrammer = $false
    [string]$WorkingDir   = "."
)

function Get-Script {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ScriptName,
        [switch]$Run = $false
    )

    $cli = New-Object System.Net.WebClient
    $cli.DownloadString("https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/intune/bin/$ScriptName") | Out-File $ScriptName

    if ($Run -eq $true) {
        ./$ScriptName
    }
}

Set-ExecutionPolicy RemoteSigned

if ((Test-Path $WorkdirDir) -eq $false) {
    New-Item $WorkingDir -ItemType Directory
}

pushd $WorkingDir

Get-Script "win-software-usermode.ps1"
Get-Script "win-software-misc.ps1"

if ($IsDeveloper -eq $true) {
    Get-Script "win-software-developer.ps1"
    Get-Script "win-software-unity.ps1"
}

if ($IsProgrammer -eq $true) {
    Get-Script "win-software-wsl.ps1"
    Get-Script "win-software-programmer.ps1"
}

popd
