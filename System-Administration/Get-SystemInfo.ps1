<#
.SYNOPSIS
    Retrieves comprehensive system information from a local or remote computer.

.DESCRIPTION
    This script gathers detailed system information including hardware, operating system,
    installed software, and network configuration. It can be run against the local machine
    or a remote computer with appropriate permissions.

.PARAMETER ComputerName
    The name of the computer to query. Defaults to the local computer.

.PARAMETER ExportPath
    Optional path to export the results as a CSV file.

.EXAMPLE
    .\Get-SystemInfo.ps1
    Retrieves system information from the local computer.

.EXAMPLE
    .\Get-SystemInfo.ps1 -ComputerName "Server01"
    Retrieves system information from the remote computer named Server01.

.EXAMPLE
    .\Get-SystemInfo.ps1 -ExportPath "C:\Reports\SystemInfo.csv"
    Retrieves system information from the local computer and exports it to a CSV file.

.NOTES
    Author: Corey Miller
    Date: April 6, 2025
    Requires: PowerShell 5.1 or later
    Requires: Administrator privileges for complete information
#>

[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [string]$ComputerName = $env:COMPUTERNAME,
    
    [Parameter()]
    [string]$ExportPath
)

function Get-SystemInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ComputerName
    )
    
    Write-Host "Gathering system information for $ComputerName..." -ForegroundColor Cyan
    
    try {
        # Operating System Information
        $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $ComputerName
        $osDetails = [PSCustomObject]@{
            ComputerName = $ComputerName
            OSName = $osInfo.Caption
            OSVersion = $osInfo.Version
            OSBuildNumber = $osInfo.BuildNumber
            OSArchitecture = $osInfo.OSArchitecture
            LastBootTime = $osInfo.LastBootUpTime
            InstallDate = $osInfo.InstallDate
            TotalVisibleMemoryGB = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 2)
            FreePhysicalMemoryGB = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
        }
        
        # Computer System Information
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem -ComputerName $ComputerName
        $computerDetails = [PSCustomObject]@{
            Manufacturer = $computerSystem.Manufacturer
            Model = $computerSystem.Model
            SystemType = $computerSystem.SystemType
            NumberOfProcessors = $computerSystem.NumberOfProcessors
            NumberOfLogicalProcessors = $computerSystem.NumberOfLogicalProcessors
            TotalPhysicalMemoryGB = [math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)
            Domain = $computerSystem.Domain
            DomainRole = $computerSystem.DomainRole
        }
        
        # Processor Information
        $processor = Get-CimInstance -ClassName Win32_Processor -ComputerName $ComputerName
        $processorDetails = [PSCustomObject]@{
            Name = $processor.Name
            Description = $processor.Description
            MaxClockSpeed = $processor.MaxClockSpeed
            NumberOfCores = $processor.NumberOfCores
            NumberOfLogicalProcessors = $processor.NumberOfLogicalProcessors
            L2CacheSize = $processor.L2CacheSize
            L3CacheSize = $processor.L3CacheSize
        }
        
        # Disk Information
        $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ComputerName $ComputerName
        $diskDetails = $disks | ForEach-Object {
            [PSCustomObject]@{
                DeviceID = $_.DeviceID
                VolumeName = $_.VolumeName
                SizeGB = [math]::Round($_.Size / 1GB, 2)
                FreeSpaceGB = [math]::Round($_.FreeSpace / 1GB, 2)
                PercentFree = [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
            }
        }
        
        # Network Adapter Information
        $networkAdapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled='True'" -ComputerName $ComputerName
        $networkDetails = $networkAdapters | ForEach-Object {
            [PSCustomObject]@{
                Description = $_.Description
                MACAddress = $_.MACAddress
                IPAddress = $_.IPAddress -join ', '
                IPSubnet = $_.IPSubnet -join ', '
                DefaultGateway = $_.DefaultIPGateway -join ', '
                DNSServers = $_.DNSServerSearchOrder -join ', '
                DHCPEnabled = $_.DHCPEnabled
                DHCPServer = $_.DHCPServer
            }
        }
        
        # Return a custom object with all the information
        $result = [PSCustomObject]@{
            OSDetails = $osDetails
            ComputerDetails = $computerDetails
            ProcessorDetails = $processorDetails
            DiskDetails = $diskDetails
            NetworkDetails = $networkDetails
        }
        
        return $result
    }
    catch {
        Write-Error "Error retrieving system information from $ComputerName. $_"
        return $null
    }
}

function Format-SystemInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$SystemInfo
    )
    
    if ($null -eq $SystemInfo) {
        return
    }
    
    # Display OS Information
    Write-Host "`n===== OPERATING SYSTEM INFORMATION =====" -ForegroundColor Green
    $SystemInfo.OSDetails | Format-List
    
    # Display Computer Information
    Write-Host "`n===== COMPUTER SYSTEM INFORMATION =====" -ForegroundColor Green
    $SystemInfo.ComputerDetails | Format-List
    
    # Display Processor Information
    Write-Host "`n===== PROCESSOR INFORMATION =====" -ForegroundColor Green
    $SystemInfo.ProcessorDetails | Format-List
    
    # Display Disk Information
    Write-Host "`n===== DISK INFORMATION =====" -ForegroundColor Green
    $SystemInfo.DiskDetails | Format-Table -AutoSize
    
    # Display Network Information
    Write-Host "`n===== NETWORK INFORMATION =====" -ForegroundColor Green
    $SystemInfo.NetworkDetails | Format-List
}

# Main execution
$systemInfo = Get-SystemInfo -ComputerName $ComputerName

# Display the information
Format-SystemInfo -SystemInfo $systemInfo

# Export to CSV if path is specified
if ($ExportPath) {
    try {
        # Create a flattened object for CSV export
        $exportData = [PSCustomObject]@{
            ComputerName = $systemInfo.OSDetails.ComputerName
            OSName = $systemInfo.OSDetails.OSName
            OSVersion = $systemInfo.OSDetails.OSVersion
            OSBuildNumber = $systemInfo.OSDetails.OSBuildNumber
            OSArchitecture = $systemInfo.OSDetails.OSArchitecture
            LastBootTime = $systemInfo.OSDetails.LastBootTime
            InstallDate = $systemInfo.OSDetails.InstallDate
            TotalVisibleMemoryGB = $systemInfo.OSDetails.TotalVisibleMemoryGB
            FreePhysicalMemoryGB = $systemInfo.OSDetails.FreePhysicalMemoryGB
            Manufacturer = $systemInfo.ComputerDetails.Manufacturer
            Model = $systemInfo.ComputerDetails.Model
            SystemType = $systemInfo.ComputerDetails.SystemType
            NumberOfProcessors = $systemInfo.ComputerDetails.NumberOfProcessors
            NumberOfLogicalProcessors = $systemInfo.ComputerDetails.NumberOfLogicalProcessors
            TotalPhysicalMemoryGB = $systemInfo.ComputerDetails.TotalPhysicalMemoryGB
            Domain = $systemInfo.ComputerDetails.Domain
            ProcessorName = $systemInfo.ProcessorDetails.Name
            ProcessorCores = $systemInfo.ProcessorDetails.NumberOfCores
            ProcessorLogicalProcessors = $systemInfo.ProcessorDetails.NumberOfLogicalProcessors
        }
        
        $exportData | Export-Csv -Path $ExportPath -NoTypeInformation
        Write-Host "`nSystem information exported to $ExportPath" -ForegroundColor Green
    }
    catch {
        Write-Error "Error exporting system information to CSV. $_"
    }
}
