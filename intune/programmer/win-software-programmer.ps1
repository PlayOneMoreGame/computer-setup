# powershell

$ScriptDir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
. "$ScriptDir/../lib/omg.ps1"

# ================================
# Admin permissions required
#=================================

choco install -y vscode
choco install -y wget
choco install -y winmerge
choco install -y golang
choco install -y jq
choco install -y make
choco install -y ripgrep
choco install -y shellcheck
choco install -y windows-sdk-10.0

# Associate "Markdown" files with VSCode to make it easy for developers to open them
cmd.exe /c assoc .md=VSCodeSourceFile

Update-Path
