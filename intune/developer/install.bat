@echo off
set moduleDir="%1\developer\"
if exist "%moduleDir%" mkdir %moduleDir%

xcopy /y win-software-developer.ps1 "%moduleDir%"
xcopy /y win-software-unity.ps1 "%moduleDir%"

pushd "%moduleDir%"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "win-software-developer.ps1"
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File "win-software-unity.ps1"
popd
