#!/usr/bin/env pwsh
# Copyright (C) 2019 One More Game - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited
# Proprietary and confidential
#
# Thanks to:
#   https://superuser.com/questions/1271682/is-there-a-way-of-installing-windows-subsystem-for-linux-on-win10-v1709-withou
#
# No thanks to:
#   The "simplicity" of PowersHell

<#
.SYNOPSIS
This script installs the OMG buildkite build agent on Windows.

.DESCRIPTION
When run normally, this script requires Administrator permissions in order to
create a user account for buildkite. When run with '-Shell', this script can
be run as Administrator or in a regular user account.

Options:
    -ResetCreds overwrite previously saved credentials
    -NoDepends  skip dependency checking to run faster (for testing)
    -WslShell   connect to Buildkite WSL account in bash
    -HostShell  connect to Buildkite host account in cmd.exe

.LINK
https://github.com/PlayOneMoreGame/core-infrastructure
#>

###############################################################################
#
#   Arguments
#
###############################################################################
Param(
  [switch]$ResetCreds = $false,
  [switch]$NoDepends = $false,
  [switch]$WslShell = $false,
  [switch]$HostShell = $false
)
Set-StrictMode -Version Latest

###############################################################################
#
#   Configuration
#
###############################################################################
$UserName = "OMG-buildkite"
$DistroUrl = "https://aka.ms/wsl-ubuntu-1804"
$DistroExeName = "ubuntu1804.exe"
$InstallDir = "C:\ProgramData\OMG\buildkite"
$Shell = $WslShell -or $HostShell
$ConfigFile = Join-Path (Get-Location) "config.env"

###############################################################################
#
#   Credentials
#
###############################################################################
# https://gallery.technet.microsoft.com/scriptcenter/Accessing-Windows-7210ae91
class StoredCredential {
  [System.Management.Automation.PSCredential] $PSCredential
  [string] $UserName;
  [string] $Password;

  # loads credential from vault
  StoredCredential([string] $name) {
    [void][Windows.Security.Credentials.PasswordVault, Windows.Security.Credentials, ContentType = WindowsRuntime]
    $vault = New-Object Windows.Security.Credentials.PasswordVault
    $cred = $vault.FindAllByResource($name) | select -First 1
    $cred.retrievePassword()
    $this.UserName = $cred.UserName
    $this.Password = $cred.Password
    $pwd_ss = ConvertTo-SecureString $cred.Password -AsPlainText -Force
    $this.PSCredential = New-Object System.Management.Automation.PSCredential ($this.UserName, $pwd_ss)
  }

  static [bool] Exists([string] $name) {
    [void][Windows.Security.Credentials.PasswordVault, Windows.Security.Credentials, ContentType = WindowsRuntime]
    $vault = New-Object Windows.Security.Credentials.PasswordVault
    try {
      $vault.FindAllByResource($name)
    }
    catch {
      if ($_.Exception.message -match "element not found") {
        return $false
      }
      throw $_.exception
    }
    return $true
  }

  static [StoredCredential] Store([string] $name, [string] $login, [string] $pwd) {
    [void][Windows.Security.Credentials.PasswordVault, Windows.Security.Credentials, ContentType = WindowsRuntime]
    $vault = New-Object Windows.Security.Credentials.PasswordVault
    $cred = New-Object Windows.Security.Credentials.PasswordCredential($name, $login, $pwd)
    $vault.Add($cred)
    return [StoredCredential]::new($name)
  }

  static [StoredCredential] Store([string] $name, [PSCredential] $pscred) {
    return [StoredCredential]::Store($name, $pscred.UserName, ($pscred.GetNetworkCredential()).Password)
  }
}

###############################################################################
#
#   Main
#
###############################################################################
# Elevate script to run as administrator
$WindowsId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($WindowsId)
if (-not $WindowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Yes, this awfulness seems to be the only way...
    if ( $ResetCreds ) { $ResetCredsStr = "-ResetCreds"; } else { $ResetCredsStr = ""; }
    if ( $NoDepends ) { $NoDependsStr = "-NoDepends"; } else { $NoDependsStr = ""; }
    if ( $WslShell ) { $WslShellStr = "-Wsl"; } else { $WslShellStr = ""; }
    if ( $HostShell ) { $HostShellStr = "-Host"; } else { $HostShellStr = ""; }

    # Re-run this script with administrative permissions.
    Start-Process powershell.exe -Wait -Verb RunAs -ArgumentList (
        # If you're having trouble debugging because the window closes, add "-NoExit" to the beginning of the string below
        "-NoProfile -ExecutionPolicy Bypass & $($MyInvocation.MyCommand.Path) $ConfigFile $ResetCredsStr $NoDependsStr $WslShellStr $HostShellStr"
    )
    exit
}

# Get user credentials
if (-not $ResetCreds -and [StoredCredential]::Exists($UserName)) {
  $creds = [StoredCredential]::New($UserName)
  Write-Host "Loaded credentials for ${UserName}"
}
else {
  try { $creds = Get-Credential -Credential $UserName } catch { return }
  $creds = [StoredCredential]::Store($UserName, $creds)
}

# Create user
if (-not $Shell) {
  $User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
  if ($null -eq $User) {
    New-LocalUser $UserName -Password $creds.PSCredential.Password -AccountNeverExpires -PasswordNeverExpires -UserMayNotChangePassword
    Write-Host "Created account for ${UserName}"
  }
  elseif ($ResetCreds) {
    Set-LocalUser $UserName -Password $creds.PSCredential.Password -AccountNeverExpires -PasswordNeverExpires $True -UserMayChangePassword $False
    Write-Host "Updated account for ${UserName}"
  }
  else {
    Write-Host "Account ${UserName} exists"
  }
}

# Ensure WSL2 is installed
if (-not $NoDepends -and -not $Shell) {
  Write-Host "Checking dependencies..."
  $MissingDependency = $False

  # Executables required
  $dependency = "nssm.exe"
  $feature = Get-Command -Name $dependency -ErrorAction SilentlyContinue
  if ($null -eq $feature) {
    Write-Host "- MISSING: ${dependency} - use 'choco install nssm'"
    $MissingDependency = $True
  }
  else {
    Write-Host "- FOUND: ${dependency}"
  }

  # Windows optional features required
  $Dependencies = @("Microsoft-Hyper-V", "Microsoft-Windows-Subsystem-Linux", "VirtualMachinePlatform")
  foreach ($Dependency in $Dependencies) {
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $Dependency -ErrorAction SilentlyContinue
    if ($null -eq $feature) {
      Write-Host "- MISSING: ${dependency} - use 'Enable-WindowsOptionalFeature -Online -FeatureName ...'"
      $MissingDependency = $True
    }
    else {
      Write-Host "- FOUND: ${dependency}"
    }
  }

  if ($MissingDependency) {
    Write-Host "FATAL: halting due to missing dependencies"
    exit 1
  }
}

# Create directories
if (-not $Shell) {
  # Create installation directory
  Write-Host "Creating buildkite directory"
  New-Item $InstallDir -ItemType Directory -Force -ErrorAction Stop
  $Acl = Get-Acl $InstallDir -ErrorAction Stop
  $AclEntry = $creds.UserName, "Modify", "Allow"
  $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($AclEntry)
  $Acl.SetAccessRule($AccessRule)
  $Acl | Set-Acl $InstallDir -ErrorAction Stop

  # Create log directory
  $LogDir = Join-Path -Path $InstallDir -ChildPath "Logs"
  $LogFile = Join-Path -Path $LogDir -ChildPath "buildkite.log"
  New-Item $LogDir -ItemType Directory -ErrorAction SilentlyContinue
  if (-not (Test-Path -Path $LogDir -PathType Container)) {
    Write-Host "ERROR: failed to create log directory ${LogDir}"
    exit 1
  }
}

# Install ubuntu
$DistroZip = Split-Path -Leaf $DistroUrl
$DistroZip = Join-Path -Path $InstallDir -ChildPath $DistroZip
$DistroZip = -join ($DistroZip, ".zip")
$DistroDir = Join-Path -Path (Split-Path -Path $DistroZip) -ChildPath (Split-Path -Leaf $DistroUrl)
$DistroExePath = Join-Path -Path $DistroDir -ChildPath $DistroExeName
if (-Not $Shell) {
  # Download distro
  if (-not (Test-Path -Path $DistroZip -PathType Leaf)) {
    Write-Host "Downloading Linux..."
    Invoke-WebRequest -Uri $DistroUrl -OutFile $DistroZip -UseBasicParsing
  }

  # Expand distro archive
  Write-Host "Expanding Linux archive..."
  Expand-Archive -Path $DistroZip -DestinationPath $DistroDir -Force

  # Run PowerShell using the buildkite account to install Linux
  if (-not (Test-Path -Path $DistroExePath -PathType Leaf)) {
    Write-Host "ERROR: Unable to find ${ExePath}"
    exit 1
  }
}

# Configure agent
if (-Not $Shell) {
  # Verify the configuration file exists
  if (-not [System.IO.File]::Exists($ConfigFile)) {
    Write-Host "ERROR: configuration file not found, ${ConfigFile}"
    exit 1
  }

  # Download entrypoint
  (New-Object System.Net.WebClient).DownloadFile("https://3xx.onemoregame.com/wsl-buildkite-setup.sh", $EntrypointDst)

  # Install configuration
  Copy-Item $ConfigFile -Destination (Join-Path -Path $InstallDir -ChildPath "config.env")

  # Set version 2 of WSL
  Write-Host "Configuring WSL"
  Start-Process -Wait -Credential $creds.PSCredential -WorkingDirectory $DistroDir -FilePath wsl.exe -ArgumentList @(
    "--set-default-version",
    "2"
  )

  # Run agent to install distro
  Write-Host "Running WSL"
  Start-Process -Wait -Credential $creds.PSCredential -WorkingDirectory $DistroDir -FilePath $DistroExePath -ArgumentList @(
    "install",
    "--root"
  )

  # JW Note: These are hardcoded because the program which can be used to convert Windows
  # paths to WSL paths (`wslpath`) must be called with `wsl`. The `wsl` command requires
  # a WSL installation and, while we just installed one, it's for a different user than
  # who is running this script. We have no guarantee that this user has a WSL installation
  # so this could result in a failure -- especially in the case of an Administrator account
  # performing the installation. Hardcoding in this was is gross, but these paths are
  # unlikely to change. Forgive me my brother or sister.
  $WSLEntrypointFile = "/mnt/c/ProgramData/OMG/buildkite/entrypoint"
  $WSLEntrypointConfig = "/mnt/c/ProgramData/OMG/buildkite/config.env"

  # Configure service
  nssm.exe install OMG-buildkite $DistroExePath
  nssm.exe set OMG-buildkite AppParameters "run ${WSLEntrypointFile} ${WSLEntrypointConfig}"
  nssm.exe set OMG-buildkite Description "OMG build server agent"
  nssm.exe set OMG-buildkite AppDirectory $InstallDir
  nssm.exe set OMG-buildkite AppStdout $LogFile
  nssm.exe set OMG-buildkite AppStderr $LogFile
  nssm.exe set OMG-buildkite Start SERVICE_AUTO_START
  nssm.exe set OMG-buildkite Type SERVICE_WIN32_OWN_PROCESS
  nssm.exe set OMG-buildkite AppStopMethodThreads 5000
  nssm.exe set OMG-buildkite AppRotateFiles 1
  nssm.exe set OMG-buildkite AppRotateOnline 1
  nssm.exe set OMG-buildkite AppRotateSeconds 86400
  nssm.exe set OMG-buildkite AppRotateBytes 1048576
  nssm.exe set OMG-buildkite ObjectName ".\${UserName}" $creds.Password

  # Start agent service
  nssm.exe start OMG-buildkite
}

###############################################################################
#
#   Debugging
#
###############################################################################
if ($WslShell) {
  Write-Host "Running WSL bash shell for diagnostics as $UserName"
  Start-Process -Wait -Credential $creds.PSCredential -WorkingDirectory $DistroDir -FilePath $DistroExePath
}
if ($HostShell) {
  Write-Host "Running host cmd shell for diagnostics as $UserName"
  Start-Process -Wait -Credential $creds.PSCredential -WorkingDirectory $DistroDir -FilePath $Env:ComSpec
}
