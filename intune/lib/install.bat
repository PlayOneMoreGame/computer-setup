@echo off
set moduleDir="%1\lib\"
if exist "%moduleDir%" mkdir %moduleDir%

xcopy /y omg.ps1 "%moduleDir%"
