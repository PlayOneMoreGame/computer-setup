@echo off
SET FNAME=%~dpn0%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "& '%FNAME%.ps1'"
