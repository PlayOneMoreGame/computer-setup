@echo off
SET FNAME=%~dpn0%
:: Run a Powershell script of the same name as this batch file with "bypass" so it will actually run on vanilla windows
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "& '%FNAME%.ps1'" %*
