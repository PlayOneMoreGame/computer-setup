@echo off
set moduleDir=c:\omg\ps\programmer\

if exist "%moduleDir%" (
    rmdir /S /Q "%moduleDir%"
)
