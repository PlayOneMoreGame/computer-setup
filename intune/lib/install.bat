@echo off
set moduleDir="%1\lib\"
if exist "%moduleDir%" mkdir %moduleDir%

xcopy /y *.* "%moduleDir%"
