#Requires -Version 5.0
<#
.SYNOPSIS
    Sign the Aeon.Net EXE with a code signing certificate
.DESCRIPTION
    Signs the compiled EXE to establish trust and authenticity
.PARAMETER CertificatePath
    Path to the PFX certificate file
.PARAMETER Password
    Certificate password
.PARAMETER TimestampUrl
    URL of the timestamp server (default: http://timestamp.comodoca.com/authenticode)
.PARAMETER EXEPath
    Path to the EXE to sign (default: dist/aeon.exe)
.EXAMPLE
    .\sign-exe.ps1 -CertificatePath "cert.pfx" -Password "mypassword"
    .\sign-exe.ps1 -CertificatePath "cert.pfx" -Password "mypassword" -TimestampUrl "http://time.certum.pl/"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$CertificatePath,

    [Parameter(Mandatory=$true)]
    [string]$Password,

    [string]$TimestampUrl = 'http://timestamp.comodoca.com/authenticode',

    [string]$EXEPath = 'dist\aeon.exe'
)

Write-Host "=== Code Signing Tool ===" -ForegroundColor Cyan
Write-Host ""

# Get the build directory
$buildDir = $PSScriptRoot
if ([string]::IsNullOrEmpty($buildDir)) {
    $buildDir = Split-Path -Parent $MyInvocation.MyCommandPath
}
if ([string]::IsNullOrEmpty($buildDir)) {
    $buildDir = Get-Location
}

# Validate certificate file
if (-not (Test-Path $CertificatePath)) {
    Write-Error "Certificate file not found: $CertificatePath"
    exit 1
}

# Validate EXE file
$buildDir = Split-Path -Parent $MyInvocation.MyCommandPath
$fullExePath = Join-Path $buildDir $EXEPath

if (-not (Test-Path $fullExePath)) {
    Write-Error "EXE file not found: $fullExePath"
    Write-Host "Run build-exe.ps1 first to create the EXE"
    exit 1
}

Write-Host "Signing EXE..." -ForegroundColor Yellow
Write-Host "  EXE: $fullExePath" -ForegroundColor Gray
Write-Host "  Certificate: $CertificatePath" -ForegroundColor Gray
Write-Host ""

try {
    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $cert.Import($CertificatePath, $Password, 'DefaultKeySet')
    
    $codeSignParams = @{
        FilePath = $fullExePath
        Certificate = $cert
        TimestampUrl = $TimestampUrl
        HashAlgorithm = 'SHA256'
    }

    Set-AuthenticodeSignature @codeSignParams | Out-Null
    
    Write-Host "[OK] EXE signed successfully" -ForegroundColor Green
    Write-Host ""
    
    # Verify signature
    $signature = Get-AuthenticodeSignature $fullExePath
    Write-Host "Signature Details:" -ForegroundColor Cyan
    Write-Host "  Status: $($signature.Status)" -ForegroundColor Green
    Write-Host "  Subject: $($signature.SignerCertificate.Subject)"
    Write-Host "  Thumbprint: $($signature.SignerCertificate.Thumbprint)"
}
catch {
    Write-Error "Failed to sign EXE: $_"
    exit 1
}
