@echo off
set moduleDir=c:\omg\ps\bootstrap\

if exist "%moduleDir%" (
    rmdir /S /Q "%moduleDir%"
)
