#Requires -Version 5.0
<#
.SYNOPSIS
    Aeon.Net DNS Resolver CLI - Standalone Version
.DESCRIPTION
    Complete DNS resolver with embedded functions. 
    This version works both as a PowerShell script and when compiled to EXE.
.NOTES
    Author: Aeon-Studios
    Version: 1.0.0
#>

param(
    [Parameter(Position=0, Mandatory=$true)]
    [ValidateSet('net', 'help', 'version')]
    [string]$Command,

    [Parameter(Position=1, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# =====================================================================
# Embedded DNS Resolver Functions (from Aeon.Net.psm1)
# =====================================================================

function Resolve-DnsHostname {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$Hostname,

        [Parameter(Mandatory=$false)]
        [ValidateSet('A', 'AAAA', 'CNAME', 'MX', 'TXT', 'NS', 'SOA', 'SRV')]
        [string]$RecordType = 'A',

        [Parameter(Mandatory=$false)]
        [string]$Nameserver
    )

    process {
        try {
            $resolveParams = @{
                Name = $Hostname
                Type = $RecordType
                ErrorAction = 'Stop'
            }

            if ($Nameserver) {
                $resolveParams['Server'] = $Nameserver
            }

            $result = Resolve-DnsName @resolveParams | Select-Object -Property Name, RecordType, RecordData, TTL, Type
            
            if ($result) {
                Write-Output $result
            } else {
                Write-Warning "No DNS records found for $Hostname ($RecordType)"
            }
        }
        catch {
            Write-Error "Failed to resolve $Hostname : $_"
        }
    }
}

function Resolve-DnsReverseIP {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$IPAddress,

        [Parameter(Mandatory=$false)]
        [string]$Nameserver
    )

    process {
        try {
            $resolveParams = @{
                Name = $IPAddress
                ErrorAction = 'Stop'
            }

            if ($Nameserver) {
                $resolveParams['Server'] = $Nameserver
            }

            $result = Resolve-DnsName @resolveParams | Select-Object -Property Name, RecordType, RecordData, TTL
            
            if ($result) {
                Write-Output $result
            } else {
                Write-Warning "No reverse DNS records found for $IPAddress"
            }
        }
        catch {
            Write-Error "Failed to reverse resolve $IPAddress : $_"
        }
    }
}

function Get-DnsMXRecords {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$Hostname,

        [Parameter(Mandatory=$false)]
        [string]$Nameserver
    )

    process {
        Resolve-DnsHostname -Hostname $Hostname -RecordType MX -Nameserver $Nameserver
    }
}

function Get-DnsTXTRecords {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$Hostname,

        [Parameter(Mandatory=$false)]
        [string]$Nameserver
    )

    process {
        Resolve-DnsHostname -Hostname $Hostname -RecordType TXT -Nameserver $Nameserver
    }
}

function Get-DnsNSRecords {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$Hostname,

        [Parameter(Mandatory=$false)]
        [string]$Nameserver
    )

    process {
        Resolve-DnsHostname -Hostname $Hostname -RecordType NS -Nameserver $Nameserver
    }
}

function Get-DnsWhois {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)]
        [string]$Hostname,

        [Parameter(Mandatory=$false)]
        [ValidateSet('A', 'AAAA', 'CNAME', 'MX', 'TXT', 'NS', 'SOA', 'SRV')]
        [string]$RecordType = 'A'
    )

    process {
        try {
            Write-Host "=========================================" -ForegroundColor Cyan
            Write-Host "DNS Query Results for: $Hostname" -ForegroundColor Yellow
            Write-Host "Record Type: $RecordType" -ForegroundColor Yellow
            Write-Host "Query Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
            Write-Host "=========================================" -ForegroundColor Cyan
            
            $results = Resolve-DnsHostname -Hostname $Hostname -RecordType $RecordType
            
            if ($results) {
                $results | Format-Table -AutoSize
                Write-Host "----------------------------------------" -ForegroundColor Cyan
                Write-Host "Total Records: $($results | Measure-Object | Select-Object -ExpandProperty Count)" -ForegroundColor Green
            }
        }
        catch {
            Write-Error "Error querying DNS for $Hostname : $_"
        }
    }
}

# =====================================================================
# CLI Functions
# =====================================================================

function Show-Help {
    @"
Aeon.Net DNS Resolver CLI v1.0.0
=================================

USAGE:
    aeon net [OPTIONS] <hostname>

COMMANDS:
    net              Perform DNS operations
    help             Show this help message
    version          Show version information

DNS OPTIONS:
    -r, --resolve    Resolve hostname to IP (A records)
    -R, --reverse    Reverse resolve IP to hostname
    -t, --type       DNS record type (A, AAAA, CNAME, MX, TXT, NS, SRV)
    -i, --info       Show detailed DNS information
    -m, --mx         Query MX records
    -x, --txt        Query TXT records
    -n, --ns         Query nameserver records
    -s, --server     Specify nameserver to query
    -h, --help       Show help for the command

EXAMPLES:
    aeon net -r example.com
    aeon net --resolve example.com
    aeon net -R 8.8.8.8
    aeon net --reverse 8.8.8.8
    aeon net -r example.com -t MX
    aeon net -r example.com --type AAAA
    aeon net -i example.com
    aeon net --info example.com
    aeon net -m example.com
    aeon net --mx example.com
    aeon net -x example.com
    aeon net --txt example.com
    aeon net -n example.com
    aeon net --ns example.com
    aeon net -r example.com -s 8.8.8.8
    aeon net -r example.com --server 1.1.1.1

"@
}

function Show-Version {
    Write-Host "Aeon.Net DNS Resolver v1.0.0"
    Write-Host "Copyright (c) 2026 Aeon-Studios"
    Write-Host "PowerShell DNS Resolution Module"
}

# =====================================================================
# Main Command Processing
# =====================================================================

switch ($Command) {
    'help' {
        Show-Help
    }
    'version' {
        Show-Version
    }
    'net' {
        # Parse arguments for the 'net' command
        $hostname = $null
        $recordType = 'A'
        $isReverse = $false
        $isInfo = $false
        $nameserver = $null
        $showHelp = $false

        for ($i = 0; $i -lt $Arguments.Count; $i++) {
            $arg = $Arguments[$i]

            switch ($arg) {
                { $_ -eq '-r' -or $_ -eq '--resolve' } {
                    if ($i + 1 -lt $Arguments.Count) {
                        $hostname = $Arguments[++$i]
                    }
                    break
                }
                { $_ -eq '-R' -or $_ -eq '--reverse' } {
                    $isReverse = $true
                    if ($i + 1 -lt $Arguments.Count) {
                        $hostname = $Arguments[++$i]
                    }
                    break
                }
                { $_ -eq '-t' -or $_ -eq '--type' } {
                    if ($i + 1 -lt $Arguments.Count) {
                        $recordType = $Arguments[++$i]
                    }
                    break
                }
                { $_ -eq '-i' -or $_ -eq '--info' } {
                    $isInfo = $true
                    if ($i + 1 -lt $Arguments.Count) {
                        $hostname = $Arguments[++$i]
                    }
                    break
                }
                { $_ -eq '-m' -or $_ -eq '--mx' } {
                    $recordType = 'MX'
                    if ($i + 1 -lt $Arguments.Count) {
                        $hostname = $Arguments[++$i]
                    }
                    break
                }
                { $_ -eq '-x' -or $_ -eq '--txt' } {
                    $recordType = 'TXT'
                    if ($i + 1 -lt $Arguments.Count) {
                        $hostname = $Arguments[++$i]
                    }
                    break
                }
                { $_ -eq '-n' -or $_ -eq '--ns' } {
                    $recordType = 'NS'
                    if ($i + 1 -lt $Arguments.Count) {
                        $hostname = $Arguments[++$i]
                    }
                    break
                }
                { $_ -eq '-s' -or $_ -eq '--server' } {
                    if ($i + 1 -lt $Arguments.Count) {
                        $nameserver = $Arguments[++$i]
                    }
                    break
                }
                { $_ -eq '-h' -or $_ -eq '--help' } {
                    $showHelp = $true
                    break
                }
                default {
                    # Treat as hostname if no flag prefix
                    if (-not $_.StartsWith('-')) {
                        $hostname = $_
                    }
                }
            }
        }

        if ($showHelp) {
            Show-Help
            exit 0
        }

        if (-not $hostname) {
            Write-Error "No hostname specified. Use 'aeon help' for usage information."
            exit 1
        }

        try {
            if ($isReverse) {
                Write-Host "Reverse DNS Lookup for: $hostname`n" -ForegroundColor Cyan
                $params = @{
                    IPAddress = $hostname
                }
                if ($nameserver) {
                    $params['Nameserver'] = $nameserver
                }
                Resolve-DnsReverseIP @params
            }
            elseif ($isInfo) {
                $params = @{
                    Hostname = $hostname
                    RecordType = $recordType
                }
                Get-DnsWhois @params
            }
            else {
                Write-Host "Resolving: $hostname (Type: $recordType)`n" -ForegroundColor Cyan
                $params = @{
                    Hostname = $hostname
                    RecordType = $recordType
                }
                if ($nameserver) {
                    $params['Nameserver'] = $nameserver
                }
                Resolve-DnsHostname @params | Format-Table -AutoSize
            }
        }
        catch {
            Write-Error "DNS query failed: $_"
            exit 1
        }
    }
    default {
        Write-Error "Unknown command: $Command"
        Show-Help
        exit 1
    }
}
