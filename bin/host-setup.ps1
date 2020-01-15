$WindowsId = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$WindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($WindowsId)
if ($WindowsPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Read input from prompt
    $AdminPasswd = Read-Host -Prompt 'Administrator account password'
    $UserName = Read-Host -Prompt 'User account name'

    ################################################
    # This code runs with administrative permissions
    ################################################

    # Enable hidden Administrator account
    net user administrator /active:yes
    net user administrator $AdminPasswd

    # Setup user account
    New-LocalUser -Name $UserName -NoPassword
    Add-LocalGroupMember -Group 'Administrators' -Member $UserName
    Add-LocalGroupMember -Group 'Users' -Member $UserName

    # Set COMPUTERNAME
    $ComputerName = "$UserName-PC"
    if ($env:COMPUTERNAME -ine $ComputerName) {
        Rename-Computer -NewName $ComputerName
    }
}
else {
    # Re-run this script with administrative permissions. Since the script may have been
    # run by piping (i.e. "iwr $Url | iex") we re-download the script from Github to run it.
    # Man, making this work was, as is typical with Powershell, a total pain.
    if ($Null -eq $MyInvocation.MyCommand.Path) {
        Write-Host "Download and run from Github"
        Start-Process powershell.exe -Wait -Verb RunAs -ArgumentList (
            # If you're having trouble debugging because the window closes, add "-NoExit" below
            "-NoProfile -ExecutionPolicy Bypass -Command iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/PlayOneMoreGame/computer-setup/master/bin/host-setup.ps1'))"
        );
    }
    else {
        Write-Host "Run script locally"
        Start-Process powershell.exe -Wait -Verb RunAs -ArgumentList (
            # If you're having trouble debugging because the window closes, add "-NoExit" below
            "-NoProfile -ExecutionPolicy Bypass -Command iex $($MyInvocation.MyCommand.Path)"
        )
    }
}