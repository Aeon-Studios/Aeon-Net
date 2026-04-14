#Requires -Version 5.0
<#
.SYNOPSIS
    Build Aeon.Net PowerShell script into a standalone EXE
.DESCRIPTION
    Uses PS2EXE to convert the aeon.ps1 script into aeon.exe
.PARAMETER Platform
    Target platform: x86 or x64 (default: x64)
.PARAMETER NoConsole
    Build without console window
.PARAMETER Compress
    Compress the output using UPX
.PARAMETER OutputPath
    Output directory for the EXE (default: dist)
.PARAMETER IconPath
    Path to ICO file for the executable
.EXAMPLE
    .\build-exe.ps1
    .\build-exe.ps1 -Platform x86
    .\build-exe.ps1 -IconPath "aeon.ico"
#>

param(
    [ValidateSet('x86', 'x64')]
    [string]$Platform = 'x64',

    [switch]$NoConsole,

    [switch]$Compress,

    [string]$OutputPath = 'dist',

    [string]$IconPath
)

# Set error action
$ErrorActionPreference = 'Stop'

# Get the build directory
$buildDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($buildDir)) {
    $buildDir = Split-Path -Parent $MyInvocation.MyCommandPath
}
if ([string]::IsNullOrEmpty($buildDir)) {
    $buildDir = Get-Location
}
$rootDir = Split-Path -Parent $buildDir
$srcDir = Join-Path $rootDir 'src'
$binDir = Join-Path $rootDir 'bin'

# Paths
$psScript = Join-Path $binDir 'aeon-standalone.ps1'
$moduleScript = Join-Path $srcDir 'Aeon.Net.psm1'
$outputDir = Join-Path $buildDir $OutputPath
$exePath = Join-Path $outputDir 'aeon.exe'

Write-Host "=== Aeon.Net EXE Build System ===" -ForegroundColor Cyan
Write-Host "Platform: $Platform" -ForegroundColor Yellow
Write-Host "Output: $exePath" -ForegroundColor Yellow
Write-Host ""

# Create output directory
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
    Write-Host "Created output directory: $outputDir" -ForegroundColor Green
}

# Check if PS2EXE is installed
Write-Host "Checking PS2EXE installation..." -ForegroundColor Cyan
$ps2exeModule = Get-Module -Name ps2exe -ListAvailable

if (-not $ps2exeModule) {
    Write-Host "PS2EXE not found. Installing..." -ForegroundColor Yellow
    
    try {
        Install-Module -Name ps2exe -Repository PSGallery -Force -AllowClobber -Scope CurrentUser
        Write-Host "PS2EXE installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install PS2EXE: $_"
        exit 1
    }
}
else {
    Write-Host "PS2EXE found: $($ps2exeModule.Version)" -ForegroundColor Green
}

# Build parameters
$ps2exeParams = @{
    inputFile = $psScript
    outputFile = $exePath
}

if ($Platform -eq 'x86') {
    $ps2exeParams['x86'] = $true
} else {
    $ps2exeParams['x64'] = $true
}

if ($NoConsole) {
    $ps2exeParams['noConsole'] = $true
}

# Import PS2EXE module
Write-Host "Importing PS2EXE module..." -ForegroundColor Cyan
Import-Module ps2exe -Force

# Build the EXE
Write-Host "Building EXE..." -ForegroundColor Cyan
try {
    Invoke-ps2exe @ps2exeParams
    Write-Host "[OK] EXE built successfully: $exePath" -ForegroundColor Green
}
catch {
    Write-Error "Failed to build EXE: $_"
    exit 1
}

# Verify the EXE exists
if (Test-Path $exePath) {
    $fileInfo = Get-Item $exePath
    $sizeKB = [math]::Round($fileInfo.Length / 1024, 2)
    Write-Host "File size: $sizeKB KB" -ForegroundColor Green
    Write-Host ""
    Write-Host "[OK] Build completed successfully!" -ForegroundColor Green
    Write-Host "EXE location: $exePath" -ForegroundColor Cyan
}
else {
    Write-Error "EXE file was not created"
    exit 1
}

# Copy batch wrapper
Write-Host ""
Write-Host "Copying batch wrapper..." -ForegroundColor Cyan
$batchFile = Join-Path $rootDir 'aeon.bat'
if (Test-Path $batchFile) {
    Copy-Item $batchFile (Join-Path $outputDir 'aeon.bat') -Force
    Write-Host "[OK] Batch wrapper copied" -ForegroundColor Green
}

# Optional: Compress with UPX
if ($Compress) {
    Write-Host ""
    Write-Host "Checking for UPX compression..." -ForegroundColor Cyan
    
    $upxPath = Get-Command upx -ErrorAction SilentlyContinue
    if ($upxPath) {
        Write-Host "Compressing EXE with UPX..." -ForegroundColor Yellow
        & upx.exe --best --lzma "$exePath"
        Write-Host "[OK] EXE compressed" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ UPX not found. Skipping compression." -ForegroundColor Yellow
        Write-Host "  Install UPX from: https://upx.github.io/" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== Build Summary ===" -ForegroundColor Cyan
Write-Host "Output Directory: $outputDir" -ForegroundColor Green
Write-Host "Main Executable: aeon.exe" -ForegroundColor Green
Write-Host "Batch Wrapper: aeon.bat" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Add '$outputDir' to your PATH"
Write-Host "  2. Or copy the files to a system folder (e.g., C:\Program Files\Aeon-Net)"
Write-Host "  3. Run: aeon version" -ForegroundColor Cyan
