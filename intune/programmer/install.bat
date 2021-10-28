@echo off
set moduleDir="%1\programmer\"
if exist "%moduleDir%" mkdir %moduleDir%

xcopy /y *.* "%moduleDir%"

pushd "%moduleDir%"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "win-software-wsl.ps1"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "win-software-programmer.ps1"
popd
