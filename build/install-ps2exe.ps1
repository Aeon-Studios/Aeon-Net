#Requires -Version 5.0
<#
.SYNOPSIS
    Install PS2EXE module for building EXE from PowerShell scripts
.DESCRIPTION
    Downloads and installs the PS2EXE module from PowerShell Gallery
.PARAMETER Scope
    Installation scope: CurrentUser or AllUsers (default: CurrentUser)
.EXAMPLE
    .\install-ps2exe.ps1
    .\install-ps2exe.ps1 -Scope AllUsers
#>

param(
    [ValidateSet('CurrentUser', 'AllUsers')]
    [string]$Scope = 'CurrentUser'
)

Write-Host "=== PS2EXE Module Installer ===" -ForegroundColor Cyan
Write-Host ""

if ($Scope -eq 'AllUsers' -and -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Administrator privileges required for AllUsers installation"
    exit 1
}

Write-Host "Installing PS2EXE module (Scope: $Scope)..." -ForegroundColor Yellow

try {
    Install-Module -Name ps2exe -Repository PSGallery -Force -AllowClobber -Scope $Scope
    Write-Host "`u{2713} PS2EXE installed successfully" -ForegroundColor Green
    Write-Host ""
    
    $module = Get-Module -Name ps2exe -ListAvailable | Select-Object -First 1
    Write-Host "Module Details:" -ForegroundColor Cyan
    Write-Host "  Name: $($module.Name)"
    Write-Host "  Version: $($module.Version)"
    Write-Host "  Path: $($module.ModuleBase)"
}
catch {
    Write-Error "Failed to install PS2EXE: $_"
    exit 1
}

Write-Host ""
Write-Host "Now run: .\build-exe.ps1" -ForegroundColor Green
