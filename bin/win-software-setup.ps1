# powershell

param(
    [switch]$IsDeveloper  = $false,
    [switch]$IsProgrammer = $false
)

function Get-Script {
    param (
        [Parameter(Mandatory=$true)]
        [string]$ScriptName,
        [switch]$Run = $false
    )

    $cli = New-Object System.Net.WebClient
    $cli.DownloadString("https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/$ScriptName") | Out-File $ScriptName

    if ($Run -eq $true) {
        ./$ScriptName
    }
}

Set-ExecutionPolicy RemoteSigned

Get-Script "win-software-usermode.ps1" -Run
Get-Script "win-software-misc.ps1" -Run

if ($IsDeveloper -eq $true) {
    Get-Script "win-software-developer.ps1" -Run
    Get-Script "win-software-unity.ps1" -Run
}

if ($IsProgrammer -eq $true) {
    Get-Script "win-software-wsl.ps1" -Run
    Get-Script "win-software-programmer.ps1" -Run
}
