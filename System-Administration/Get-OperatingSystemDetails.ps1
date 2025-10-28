function Get-OperatingSystemDetails {
    <#
        .SYNOPSIS
        Get operating system details of a computer
        .DESCRIPTION   
        This cmdlet retrieves detailed information about the operating system of a specified computer using CIM.
        .PARAMETER ComputerName
        The name of the computer to query.
        .EXAMPLE
        Get-OperatingSystemDetails -ComputerName "Server01"
        This example retrieves the operating system details of the computer named "Server01".
        .EXAMPLE
        Get-OperatingSystemDetails -ComputerName "Server02"
        This example retrieves the operating system details of the computer named "Server02".
        .INPUTS
        String - Computer name(s) to query
        .OUTPUTS
        PSCustomObject - Operating system details including name, version, architecture, and memory information
        .NOTES
        This cmdlet is designed to work with Windows operating systems.
        .FUNCTIONALITY
        System Administration 
    #>
    [CmdletBinding(SupportsShouldProcess=$true,
        PositionalBinding=$true,
        ConfirmImpact = 'Low')]
    [OutputType([PSCustomObject])]
    param (
        # Computer name(s) to query
        [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ValidateNotNullOrEmpty()]
        [ArgumentCompletions('localhost')]
        [Alias("CN", "ServerName")]
        [String[]]$ComputerName

    )

    begin {
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Debug "Entering function: $FunctionName" 
        $Count = 0 
    }#begin

    process {
        foreach ($name in $ComputerName) {
            if ($pscmdlet.ShouldProcess($name, "Retrieve operating system details")) {
                # Retrieve operating system details using Get-CimInstance
                try {
                    Write-Debug ("{0} called {1} time(s): Processing computer: {2}" -f $FunctionName, (++$Count), $name)
                    Write-Debug "Using Get-CimInstance to query Win32_OperatingSystem on $name"
                    Write-Debug 'CIM Query: SELECT * FROM Win32_OperatingSystem'
                    Write-Verbose "Retrieving operating system details for $name"
                    Write-Information "Querying operating system information from $name"

                    $osInfo = Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $name -ErrorAction Stop
                    $osDetails = [PSCustomObject]@{
                        ComputerName         = $name
                        OSName               = $osInfo.Caption
                        OSVersion            = $osInfo.Version
                        OSBuildNumber        = $osInfo.BuildNumber
                        OSArchitecture       = $osInfo.OSArchitecture
                        LastBootTime         = $osInfo.LastBootUpTime
                        InstallDate          = $osInfo.InstallDate
                        TotalVisibleMemoryGB = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 2)
                        FreePhysicalMemoryGB = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
                    }

                    Write-Debug "Operating System Information: $($osDetails | Format-List | Out-String)"
                    Write-Verbose "Successfully retrieved operating system details for $name"
                    Write-Information "Operating system details retrieved successfully from $name"

                    # Emit the result for this computer
                    $osDetails
                    
                }
                catch {
                    # Handle errors that occur during the retrieval of operating system details
                    $ErrorMessage = $_.Exception.Message
                    Write-Error "Error occured in Function $FunctionName"
                    Write-Error "Failed to retrieve operating system details from $name. Error: $ErrorMessage"
                    Write-Debug "Error occurred in function: $FunctionName"
                    Write-Debug "Error details: $ErrorMessage"
                    Write-Debug "Exiting function iteration due to error"
                    Write-Verbose "An error occurred while retrieving operating system details for $name"
                    Write-Information "Failed to retrieve operating system details from $name"
                    Write-Information "Exiting function iteration due to error: $ErrorMessage"
                    # Emit a placeholder result so that the output count matches the input count
                    [PSCustomObject]@{
                        ComputerName         = $name
                        OSName               = $null
                        OSVersion            = $null
                        OSBuildNumber        = $null
                        OSArchitecture       = $null
                        LastBootTime         = $null
                        InstallDate          = $null
                        TotalVisibleMemoryGB = $null
                        FreePhysicalMemoryGB = $null
                        ErrorMessage         = $ErrorMessage
                    }
                    # Continue processing other names
                }
            }
        }
        Write-Debug "Exiting function: $FunctionName successfully"
    }#process

    end {
        #Intententonally left blank    
    }#end

}#function