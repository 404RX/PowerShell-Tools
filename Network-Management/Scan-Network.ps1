<#
.SYNOPSIS
    Scans a network range for active hosts and open ports.

.DESCRIPTION
    This script performs a network scan on a specified IP range to discover active hosts
    and optionally checks for open ports on those hosts. Results can be displayed in the
    console or exported to a CSV file.

.PARAMETER IPRange
    The IP range to scan in CIDR notation (e.g., 192.168.1.0/24) or as a start-end range (e.g., 192.168.1.1-192.168.1.254).

.PARAMETER Ports
    An array of ports to scan on each active host. Default is 22, 80, 443, 3389, 5985.

.PARAMETER Timeout
    The timeout in milliseconds for each ping and port scan attempt. Default is 1000ms.

.PARAMETER ExportPath
    Optional path to export the results as a CSV file.

.EXAMPLE
    .\Scan-Network.ps1 -IPRange "192.168.1.0/24"
    Scans the 192.168.1.0/24 network for active hosts and checks default ports.

.EXAMPLE
    .\Scan-Network.ps1 -IPRange "10.0.0.1-10.0.0.50" -Ports 22,80,443,8080 -Timeout 500
    Scans the IP range from 10.0.0.1 to 10.0.0.50 for active hosts and checks the specified ports with a 500ms timeout.

.EXAMPLE
    .\Scan-Network.ps1 -IPRange "192.168.1.0/24" -ExportPath "C:\Reports\NetworkScan.csv"
    Scans the 192.168.1.0/24 network and exports the results to a CSV file.

.NOTES
    Author: Corey Miller
    Date: April 6, 2025
    Requires: PowerShell 5.1 or later
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$IPRange,
    
    [Parameter()]
    [int[]]$Ports = @(22, 80, 443, 3389, 5985),
    
    [Parameter()]
    [int]$Timeout = 1000,
    
    [Parameter()]
    [string]$ExportPath
)

# Function to expand IP range from CIDR notation
function Expand-IPRangeCIDR {
    param (
        [Parameter(Mandatory = $true)]
        [string]$CIDR
    )
    
    if ($CIDR -match '^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/(\d{1,2})$') {
        $BaseIP = $Matches[1]
        $Prefix = [int]$Matches[2]
        
        if ($Prefix -lt 0 -or $Prefix -gt 32) {
            Write-Error "Invalid CIDR prefix. Must be between 0 and 32."
            return $null
        }
        
        # Parse the IP address
        $IP = $BaseIP -split '\.'
        $IPNum = ([int]$IP[0] -shl 24) + ([int]$IP[1] -shl 16) + ([int]$IP[2] -shl 8) + [int]$IP[3]
        
        # Calculate the network and broadcast addresses
        $NetworkMask = (-bnot 0) -shl (32 - $Prefix)
        $NetworkAddress = $IPNum -band $NetworkMask
        $BroadcastAddress = $NetworkAddress -bor ((-bnot 0) -shr $Prefix)
        
        # Generate all IP addresses in the range (excluding network and broadcast)
        $IPs = @()
        for ($i = $NetworkAddress + 1; $i -lt $BroadcastAddress; $i++) {
            $Octet1 = ($i -shr 24) -band 255
            $Octet2 = ($i -shr 16) -band 255
            $Octet3 = ($i -shr 8) -band 255
            $Octet4 = $i -band 255
            $IPs += "$Octet1.$Octet2.$Octet3.$Octet4"
        }
        
        return $IPs
    }
    else {
        Write-Error "Invalid CIDR format. Expected format: x.x.x.x/y"
        return $null
    }
}

# Function to expand IP range from start-end notation
function Expand-IPRangeStartEnd {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Range
    )
    
    if ($Range -match '^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})-(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})$') {
        $StartIP = $Matches[1]
        $EndIP = $Matches[2]
        
        # Parse the IP addresses
        $StartIPParts = $StartIP -split '\.'
        $EndIPParts = $EndIP -split '\.'
        
        $StartIPNum = ([int]$StartIPParts[0] -shl 24) + ([int]$StartIPParts[1] -shl 16) + ([int]$StartIPParts[2] -shl 8) + [int]$StartIPParts[3]
        $EndIPNum = ([int]$EndIPParts[0] -shl 24) + ([int]$EndIPParts[1] -shl 16) + ([int]$EndIPParts[2] -shl 8) + [int]$EndIPParts[3]
        
        if ($StartIPNum -gt $EndIPNum) {
            Write-Error "Start IP must be less than or equal to End IP."
            return $null
        }
        
        # Generate all IP addresses in the range
        $IPs = @()
        for ($i = $StartIPNum; $i -le $EndIPNum; $i++) {
            $Octet1 = ($i -shr 24) -band 255
            $Octet2 = ($i -shr 16) -band 255
            $Octet3 = ($i -shr 8) -band 255
            $Octet4 = $i -band 255
            $IPs += "$Octet1.$Octet2.$Octet3.$Octet4"
        }
        
        return $IPs
    }
    else {
        Write-Error "Invalid IP range format. Expected format: x.x.x.x-y.y.y.y"
        return $null
    }
}

# Function to test if a port is open
function Test-PortOpen {
    param (
        [Parameter(Mandatory = $true)]
        [string]$IPAddress,
        
        [Parameter(Mandatory = $true)]
        [int]$Port,
        
        [Parameter(Mandatory = $true)]
        [int]$Timeout
    )
    
    $TCPClient = New-Object System.Net.Sockets.TcpClient
    
    try {
        $AsyncResult = $TCPClient.BeginConnect($IPAddress, $Port, $null, $null)
        $WaitResult = $AsyncResult.AsyncWaitHandle.WaitOne($Timeout, $false)
        
        if ($WaitResult) {
            try {
                $TCPClient.EndConnect($AsyncResult)
                return $true
            }
            catch {
                return $false
            }
        }
        else {
            return $false
        }
    }
    catch {
        return $false
    }
    finally {
        $TCPClient.Close()
    }
}

# Main function to scan the network
function Scan-Network {
    param (
        [Parameter(Mandatory = $true)]
        [string]$IPRange,
        
        [Parameter(Mandatory = $true)]
        [int[]]$Ports,
        
        [Parameter(Mandatory = $true)]
        [int]$Timeout
    )
    
    Write-Host "Starting network scan of $IPRange..." -ForegroundColor Cyan
    
    # Expand IP range
    $IPs = @()
    if ($IPRange -match '/') {
        $IPs = Expand-IPRangeCIDR -CIDR $IPRange
    }
    else {
        $IPs = Expand-IPRangeStartEnd -Range $IPRange
    }
    
    if ($null -eq $IPs -or $IPs.Count -eq 0) {
        Write-Error "Failed to parse IP range or no valid IPs found."
        return
    }
    
    Write-Host "Scanning $($IPs.Count) IP addresses..." -ForegroundColor Cyan
    
    $Results = @()
    $PingJobs = @()
    
    # Start ping jobs for all IPs
    foreach ($IP in $IPs) {
        $PingJobs += Start-Job -ScriptBlock {
            param ($IP, $Timeout)
            
            $Ping = New-Object System.Net.NetworkInformation.Ping
            try {
                $Result = $Ping.Send($IP, $Timeout)
                if ($Result.Status -eq "Success") {
                    return @{
                        IPAddress = $IP
                        Status = "Online"
                        ResponseTime = $Result.RoundtripTime
                    }
                }
            }
            catch {
                # Ping failed
            }
            
            return $null
        } -ArgumentList $IP, $Timeout
    }
    
    # Wait for all ping jobs to complete
    $CompletedCount = 0
    $TotalCount = $PingJobs.Count
    
    foreach ($Job in $PingJobs) {
        $Result = Receive-Job -Job $Job -Wait
        Remove-Job -Job $Job
        
        $CompletedCount++
        Write-Progress -Activity "Pinging hosts" -Status "$CompletedCount of $TotalCount complete" -PercentComplete (($CompletedCount / $TotalCount) * 100)
        
        if ($Result) {
            $Results += $Result
        }
    }
    
    Write-Progress -Activity "Pinging hosts" -Completed
    
    # Scan ports for online hosts
    $OnlineHosts = $Results | Where-Object { $_.Status -eq "Online" }
    $HostCount = $OnlineHosts.Count
    $CompletedCount = 0
    
    Write-Host "Found $HostCount online hosts. Scanning ports..." -ForegroundColor Cyan
    
    foreach ($Host in $OnlineHosts) {
        $OpenPorts = @()
        
        foreach ($Port in $Ports) {
            $PortOpen = Test-PortOpen -IPAddress $Host.IPAddress -Port $Port -Timeout $Timeout
            if ($PortOpen) {
                $OpenPorts += $Port
            }
        }
        
        $Host | Add-Member -MemberType NoteProperty -Name "OpenPorts" -Value $OpenPorts
        
        $CompletedCount++
        Write-Progress -Activity "Scanning ports" -Status "$CompletedCount of $HostCount hosts complete" -PercentComplete (($CompletedCount / $HostCount) * 100)
        
        # Display results for this host
        Write-Host "Host $($Host.IPAddress) is online. Response time: $($Host.ResponseTime)ms" -ForegroundColor Green
        
        if ($OpenPorts.Count -gt 0) {
            Write-Host "  Open ports: $($OpenPorts -join ', ')" -ForegroundColor Yellow
        }
        else {
            Write-Host "  No open ports found" -ForegroundColor Gray
        }
    }
    
    Write-Progress -Activity "Scanning ports" -Completed
    
    return $OnlineHosts
}

# Main execution
try {
    $ScanResults = Scan-Network -IPRange $IPRange -Ports $Ports -Timeout $Timeout
    
    # Display summary
    Write-Host "`n===== SCAN SUMMARY =====" -ForegroundColor Green
    Write-Host "Total hosts scanned: $($ScanResults.Count)" -ForegroundColor Cyan
    
    # Export to CSV if path is specified
    if ($ExportPath) {
        try {
            # Create a flattened object for CSV export
            $ExportData = $ScanResults | ForEach-Object {
                [PSCustomObject]@{
                    IPAddress = $_.IPAddress
                    Status = $_.Status
                    ResponseTime = $_.ResponseTime
                    OpenPorts = $_.OpenPorts -join ', '
                }
            }
            
            $ExportData | Export-Csv -Path $ExportPath -NoTypeInformation
            Write-Host "`nScan results exported to $ExportPath" -ForegroundColor Green
        }
        catch {
            Write-Error "Error exporting scan results to CSV. $_"
        }
    }
}
catch {
    Write-Error "Error during network scan: $_"
}
