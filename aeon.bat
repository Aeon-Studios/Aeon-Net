@echo off
REM Aeon.Net CLI Launcher for Windows Batch
REM This script allows calling aeon.ps1 directly from Command Prompt or PowerShell

setlocal enabledelayedexpansion

REM Get the directory of this batch file
set SCRIPT_DIR=%~dp0

REM Call PowerShell with the aeon.ps1 script
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%bin\aeon.ps1" %*

endlocal
