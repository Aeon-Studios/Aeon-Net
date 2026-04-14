# Aeon.Net Installation Guide

## Prerequisites
- Windows PowerShell 5.0 or PowerShell 7.0+
- Administrator privileges (recommended for system-wide installation)

## Installation Methods

### Method 1: Add to PATH (Recommended)

1. **Copy the binary**:
   - Copy the `bin` folder to a known location, or add it to your PATH

2. **Add to System PATH**:
   ```powershell
   # Run as Administrator
   $aeonPath = "C:\Users\dchua\OneDrive\Documents\GitHub\Aeon-Net\bin"
   [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$aeonPath", "Machine")
   ```

3. **Verify Installation**:
   ```powershell
   aeon version
   ```

### Method 2: Create PowerShell Alias

Add this to your PowerShell profile (`$PROFILE`):

```powershell
# Add Aeon.Net alias
$aeonPath = "C:\Users\dchua\OneDrive\Documents\GitHub\Aeon-Net\bin\aeon.ps1"
Set-Alias -Name aeon -Value $aeonPath -Force
```

Then reload your profile:
```powershell
& $PROFILE
```

### Method 3: Create Windows Batch Wrapper

Create a file named `aeon.bat` in a folder that's in your PATH:

```batch
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\Users\dchua\OneDrive\Documents\GitHub\Aeon-Net\bin\aeon.ps1" %*
```

## Usage Examples

### Basic DNS Resolution
```powershell
aeon net -r example.com
aeon net --resolve example.com
```

### Query Specific Record Type
```powershell
aeon net -r example.com -t MX
aeon net -r example.com --type AAAA
```

### Mail Server Records
```powershell
aeon net -m example.com
aeon net --mx example.com
```

### TXT Records (SPF, DKIM, etc.)
```powershell
aeon net -x example.com
aeon net --txt example.com
```

### Nameserver Records
```powershell
aeon net -n example.com
aeon net --ns example.com
```

### Reverse DNS Lookup
```powershell
aeon net -R 8.8.8.8
aeon net --reverse 8.8.8.8
```

### Detailed Information
```powershell
aeon net -i example.com
aeon net --info example.com
```

### Query Specific Nameserver
```powershell
aeon net -r example.com -s 8.8.8.8
aeon net -r example.com --server 1.1.1.1
```

### Show Help
```powershell
aeon help
aeon net -h
aeon net --help
```

### Show Version
```powershell
aeon version
```

## Troubleshooting

### "aeon.ps1 cannot be loaded because running scripts is disabled"
Run PowerShell as Administrator and execute:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Module not found error
Ensure the directory structure is intact:
```
Aeon-Net/
├── bin/
│   └── aeon.ps1
├── src/
│   └── Aeon.Net.psm1
└── ...
```

### PATH not updated
After adding to PATH, you may need to restart your terminal or run:
```powershell
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")
```

## Uninstallation

### Remove from PATH
```powershell
# Remove from PATH
$path = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$newPath = $path -replace ";?C:\\Users\\dchua\\OneDrive\\Documents\\GitHub\\Aeon-Net\\bin;?", ""
[Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
```

### Remove Alias
Remove the alias line from your PowerShell profile (`$PROFILE`).

## Support

For issues or feature requests, please refer to the repository's issue tracker.

