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

# Install "scoop" package manager
if (Get-Command -Name "scoop" -ErrorAction SilentlyContinue) {
    scoop update
} else {
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# Install github command-line tool
if (scoop list gh 2>&1 | Out-Null) {
    scoop bucket add github-gh "https://github.com/cli/scoop-gh.git"
    scoop install gh
} else {
    scoop update gh
}

# Replacement for unix find
if (scoop list fd 2>&1 | Out-Null) {
    scoop install fd
} else {
    scoop update fd
}

# Python
if (scoop list python 2>&1 | Out-Null) {
    scoop install python
} else {
    scoop update python
}
