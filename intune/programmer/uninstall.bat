@echo off
set moduleDir="%1\programmer\"

if exist "%moduleDir%" (
    rmdir /S /Q "%moduleDir%"
)
