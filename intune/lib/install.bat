@echo off
set moduleDir=c:\omg\ps\lib\
if exist "%moduleDir%" mkdir %moduleDir%

xcopy /y omg.ps1 "%moduleDir%"
