@echo off
set moduleDir="%1\bootstrap\"
if exist "%moduleDir%" mkdir %moduleDir%

xcopy /y *.* "%moduleDir%"

pushd "%moduleDir%"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "win-software-usermode.ps1"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "win-software-misc.ps1"
popd
