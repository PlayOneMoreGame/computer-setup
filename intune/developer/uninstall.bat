@echo off
set moduleDir=c:\omg\ps\developer\

if exist "%moduleDir%" (
    rmdir /S /Q "%moduleDir%"
)
