@echo off
set moduleDir="%1\bootstrap\"

if exist "%moduleDir%" (
    rmdir /S /Q "%moduleDir%"
)
