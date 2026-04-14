# Aeon.Net EXE Build System

This directory contains scripts and tools to build the Aeon.Net PowerShell DNS resolver into a standalone Windows EXE.

## Prerequisites

- PowerShell 5.0 or later
- .NET Framework 4.5.2 or later (for PS2EXE)
- Administrator access (for some installation steps)

## Quick Build

### Option 1: Using build-exe.ps1 (Recommended)

```powershell
cd build
.\build-exe.ps1
```

This will:
1. Install PS2EXE if not already installed
2. Compile the PowerShell scripts into `aeon.exe`
3. Place the EXE in the `dist` folder
4. Create a portable package

### Option 2: Manual Build

```powershell
cd build

# Install PS2EXE (one-time only)
.\install-ps2exe.ps1

# Build the EXE
.\build-exe.ps1

# Optional: Code sign the EXE
.\sign-exe.ps1 -CertificatePath "path\to\cert.pfx" -Password "password"
```

## Output

The built EXE will be located in:
- **Single file**: `build\dist\aeon.exe`
- **With installer**: `build\dist\aeon-installer.exe`

## Distribution

### Standalone Distribution
1. Copy `build\dist\aeon.exe` to users
2. Users place it in any folder and add to PATH
3. Or use the batch wrapper: `aeon.bat`

### Packaged Installer
Create a professional installer using Windows Installer XML (WIX):
```powershell
.\build\create-installer.ps1
```

## Code Signing (Optional)

To sign the EXE with your certificate:
```powershell
.\sign-exe.ps1 -CertificatePath "cert.pfx" -Password "yourpassword"
```

## Version Management

Update the version in:
- `build\version.txt`
- `src\Aeon.Net.psm1` (in the .NOTES section)
- `bin\aeon.ps1` (CLI version display)

## Troubleshooting

### PS2EXE Installation Fails
```powershell
Install-Module ps2exe -Repository PSGallery -Force
```

### "Cannot find module PS2EXE"
Ensure it's installed globally:
```powershell
Get-Module PS2EXE -ListAvailable
```

### EXE is flagged by antivirus
This is common for newly-built executables. You can:
1. Code sign the EXE
2. Submit to antivirus vendors for whitelisting
3. Build incrementally to establish reputation

### EXE won't run
Ensure target machine has .NET Framework 4.5.2 or later installed.

## Advanced Options

### Compression
Use UPX for smaller file size:
```powershell
.\build-exe.ps1 -Compress
```

### Console vs Windowed
```powershell
# Console window (default)
.\build-exe.ps1

# No console window
.\build-exe.ps1 -NoConsole
```

### 32-bit vs 64-bit
```powershell
# 64-bit (default)
.\build-exe.ps1 -Platform x64

# 32-bit
.\build-exe.ps1 -Platform x86
```

## Support

For issues with the build process, see troubleshooting in the main README.md or open an issue on GitHub.
