@echo off
set moduleDir=c:\omg\ps\lib\

if exist "%moduleDir%" (
    rmdir /S /Q "%moduleDir%"
)
