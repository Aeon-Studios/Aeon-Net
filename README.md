# Aeon-Net

Lightweight PowerShell DNS resolver CLI for fast and flexible DNS queries. Aeon-Net provides command-line DNS resolution with support for multiple record types, reverse lookups, and detailed query information.

## Features

- **Fast DNS Resolution**: Query A, AAAA, CNAME, MX, TXT, NS, and SRV records
- **Reverse DNS Lookup**: Resolve IP addresses back to hostnames
- **Mail Server Queries**: Get MX records for email configuration
- **SPF/DKIM Verification**: Query TXT records for email authentication
- **Custom Nameserver**: Query specific nameservers
- **Detailed Information**: View comprehensive DNS query results
- **Simple CLI**: Easy-to-use command structure with `aeon net` prefix

## Installation

### Option 1: Standalone EXE (Recommended)
Download the latest `aeon.exe` release and place it in a folder that's in your PATH, or run from any location.

### Option 2: PowerShell Script

1. **Clone or download the repository**:
   ```powershell
   git clone https://github.com/Aeon-Studios/Aeon-Net.git
   cd Aeon-Net
   ```

2. **Add to PATH**:
   ```powershell
   # Run as Administrator
   $aeonPath = "<path-to-aeon-net>\bin"
   [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$aeonPath", "Machine")
   ```

For detailed installation options, see [INSTALL.md](INSTALL.md).

## Usage

### Basic Commands

All commands start with **`aeon net`**:

#### Resolve Hostnames
```powershell
# Resolve domain to IP address
aeon net -r example.com
aeon net --resolve example.com

# Resolve with custom nameserver
aeon net -r example.com -s 8.8.8.8
aeon net -r example.com --server 1.1.1.1
```

#### Query Specific Record Types
```powershell
aeon net -r example.com -t AAAA          # IPv6 records
aeon net -r example.com --type MX        # Mail servers
aeon net -r example.com --type TXT       # Text records
aeon net -r example.com --type NS        # Nameservers
```

#### Mail Server Records
```powershell
aeon net -m example.com
aeon net --mx example.com
```

#### TXT Records (SPF, DKIM, etc.)
```powershell
aeon net -x example.com
aeon net --txt example.com
```

#### Nameserver Records
```powershell
aeon net -n example.com
aeon net --ns example.com
```

#### Reverse DNS Lookup
```powershell
# Resolve IP address back to hostname
aeon net -R 8.8.8.8
aeon net --reverse 8.8.8.8
```

#### Detailed Information
```powershell
# Show comprehensive DNS query results
aeon net -i example.com
aeon net --info example.com
```

#### Help & Version
```powershell
aeon help                 # Show help
aeon net -h              # Show net command help
aeon net --help          # Show net command help
aeon version             # Show version information
```

### Command Reference

```
USAGE:
    aeon net [OPTIONS] <hostname>

OPTIONS:
    -r, --resolve    Resolve hostname to IP (A records)
    -R, --reverse    Reverse resolve IP to hostname
    -t, --type       DNS record type (A, AAAA, CNAME, MX, TXT, NS, SRV)
    -i, --info       Show detailed DNS information
    -m, --mx         Query MX records
    -x, --txt        Query TXT records
    -n, --ns         Query nameserver records
    -s, --server     Specify nameserver to query
    -h, --help       Show help for the command
```

## Project Structure

```
Aeon-Net/
├── bin/
│   └── aeon.ps1              # Main CLI entry point
├── src/
│   └── Aeon.Net.psm1         # PowerShell module with DNS functions
├── aeon.bat                  # Windows batch wrapper
├── INSTALL.md                # Detailed installation guide
├── README.md                 # This file
└── LICENSE                   # License file
```

## Usage Examples

### Resolve a Domain
```powershell
PS> aeon net -r google.com

Resolving: google.com (Type: A)

Name                  RecordType RecordData        TTL Type
----                  ---------- ----------        --- ----
google.com            A          142.251.41.14     300 1
google.com            A          142.251.41.46     300 1
```

### Check Mail Server
```powershell
PS> aeon net -m example.com

Mail servers for example.com:
...
```

### Reverse Lookup
```powershell
PS> aeon net -R 8.8.8.8

Reverse DNS Lookup for: 8.8.8.8

Name                  RecordType RecordData
----                  ---------- ----------
dns.google            PTR        dns.google
```

### Detailed Query
```powershell
PS> aeon net -i example.com

=========================================
DNS Query Results for: example.com
Record Type: A
Query Time: 2026-04-13 10:30:45
=========================================
...
```

## Requirements

- **EXE Version**: Windows 7 or later (no additional requirements)
- **PowerShell Version**: Windows PowerShell 5.0 or PowerShell 7.0+

## Troubleshooting

### EXE not found after installation
- Ensure the folder containing `aeon.exe` is in your PATH
- Restart your terminal after adding to PATH
- Run `aeon version` to verify installation

### "aeon.ps1 cannot be loaded because running scripts is disabled" (PowerShell version)

Fix by allowing script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Contributing

Contributions are welcome! Please open issues and pull requests for bugs and features.

## License

See the [LICENSE](LICENSE) file for details.

## Support

For issues or questions, please open an issue on the repository.

---

**Aeon-Net** - Fast DNS Resolution for PowerShell
