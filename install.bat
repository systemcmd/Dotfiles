@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%windows\install.ps1"
set "EXITCODE=%ERRORLEVEL%"

if "%CI%"=="" pause
exit /b %EXITCODE%
