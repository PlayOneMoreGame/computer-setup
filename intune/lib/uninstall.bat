@echo off
set moduleDir="%1\lib\"

if exist "%moduleDir%" (
    rmdir /S /Q "%moduleDir%"
)
