@echo off
set moduleDir="%1\developer\"

if exist "%moduleDir%" (
    rmdir /S /Q "%moduleDir%"
)
