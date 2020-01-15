@echo off
SET DIR=%~dp0%
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "& '%DIR%host-setup.ps1'"
