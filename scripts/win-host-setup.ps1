# powershell

param(
    [switch]$IsDeveloper  = $false,
    [switch]$IsProgrammer = $false,
    [string]$WorkingDir   = ".",
    [string]$Branch       = "master"
)

function Get-Script {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ScriptName,
        [switch]$Run = $false
    )

    $cli = New-Object System.Net.WebClient
    $cli.DownloadString("https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/$Branch/intune/$ScriptName") | Out-File $ScriptName

    if ($Run -eq $true) {
        ./$ScriptName
    }
}

if ((Test-Path $WorkingDir) -eq $false) {
    New-Item $WorkingDir -ItemType Directory
}

pushd $WorkingDir

Get-Script "lib/omg.ps1"
Get-Script "bootstrap/win-software-usermode.ps1" -Run
Get-Script "bootstrap/win-software-misc.ps1" -Run

if ($IsDeveloper -eq $true) {
    Get-Script "developer/win-software-developer.ps1" -Run
    Get-Script "developer/win-software-unity.ps1" -Run
}

if ($IsProgrammer -eq $true) {
    Get-Script "programmer/win-software-wsl.ps1" -Run
    Get-Script "programmer/win-software-programmer.ps1" -Run
}

popd
