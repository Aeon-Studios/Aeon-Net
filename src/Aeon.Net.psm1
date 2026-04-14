#Requires -Version 5.0
<#
.SYNOPSIS
    Aeon.Net - PowerShell DNS Resolver Module
.DESCRIPTION
    A comprehensive DNS resolver module for PowerShell enabling fast and flexible DNS queries.
.NOTES
    Author: Aeon-Studios
    Version: 1.0.0
#>

# DNS Resolver Functions

<#
.SYNOPSIS
    Resolves DNS queries for hostnames
.DESCRIPTION
    Performs DNS resolution for the specified hostname, returning A, AAAA, CNAME, MX, and other records.
.PARAMETER Hostname
    The hostname or domain to resolve
.PARAMETER RecordType
    The type of DNS record to query (A, AAAA, CNAME, MX, TXT, NS, SOA, SRV)
.PARAMETER Nameserver
    Optional specific nameserver to query
.EXAMPLE
    Resolve-DnsHostname -Hostname example.com
    Resolve-DnsHostname -Hostname example.com -RecordType MX
#>
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

<#
.SYNOPSIS
    Performs reverse DNS lookup
.DESCRIPTION
    Resolves an IP address to its hostname (reverse lookup)
.PARAMETER IPAddress
    The IP address to reverse resolve
.PARAMETER Nameserver
    Optional specific nameserver to query
.EXAMPLE
    Resolve-DnsReverseIP -IPAddress 8.8.8.8
#>
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

<#
.SYNOPSIS
    Queries DNS MX records for mail servers
.DESCRIPTION
    Retrieves Mail Exchange (MX) records for a domain
.PARAMETER Hostname
    The domain to query for MX records
.PARAMETER Nameserver
    Optional specific nameserver to query
.EXAMPLE
    Get-DnsMXRecords -Hostname example.com
#>
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

<#
.SYNOPSIS
    Queries DNS TXT records
.DESCRIPTION
    Retrieves TXT records for a domain (SPF, DKIM, etc.)
.PARAMETER Hostname
    The domain to query for TXT records
.PARAMETER Nameserver
    Optional specific nameserver to query
.EXAMPLE
    Get-DnsTXTRecords -Hostname example.com
#>
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

<#
.SYNOPSIS
    Queries DNS NS records for nameservers
.DESCRIPTION
    Retrieves Nameserver (NS) records for a domain
.PARAMETER Hostname
    The domain to query for NS records
.PARAMETER Nameserver
    Optional specific nameserver to query
.EXAMPLE
    Get-DnsNSRecords -Hostname example.com
#>
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

<#
.SYNOPSIS
    Displays DNS query information in detailed format
.DESCRIPTION
    Performs a DNS resolution and displays detailed output with query statistics
.PARAMETER Hostname
    The hostname or domain to resolve
.PARAMETER RecordType
    The type of DNS record to query
.EXAMPLE
    Get-DnsWhois -Hostname example.com
    Get-DnsWhois -Hostname example.com -RecordType MX
#>
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

# Export functions
Export-ModuleMember -Function @(
    'Resolve-DnsHostname',
    'Resolve-DnsReverseIP',
    'Get-DnsMXRecords',
    'Get-DnsTXTRecords',
    'Get-DnsNSRecords',
    'Get-DnsWhois'
)
