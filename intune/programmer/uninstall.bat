@echo off
set moduleDir="%~dp0\"

if exist "%moduleDir%" (
    rmdir /S /Q "%moduleDir%"
)
