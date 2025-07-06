<#
.SYNOPSIS
    Common test setup and helper functions for PowerShell-Tools tests
.DESCRIPTION
    This module provides common setup, cleanup, and utility functions used across all test files.
    It ensures consistent test environment setup and provides reusable test helpers.
#>

# Global test variables
$script:TestDataPath = Join-Path $PSScriptRoot "TestData"
$script:TempTestPath = Join-Path $env:TEMP "PowerShell-Tools-Tests"

# Common test setup function
function Initialize-TestEnvironment {
    [CmdletBinding()]
    param()
    
    # Create temp directory for tests
    if (!(Test-Path $script:TempTestPath)) {
        New-Item -ItemType Directory -Path $script:TempTestPath -Force | Out-Null
    }
    
    # Set up test data directory
    if (!(Test-Path $script:TestDataPath)) {
        New-Item -ItemType Directory -Path $script:TestDataPath -Force | Out-Null
    }
}

# Common test cleanup function
function Clear-TestEnvironment {
    [CmdletBinding()]
    param()
    
    # Clean up temp directory
    if (Test-Path $script:TempTestPath) {
        Remove-Item -Path $script:TempTestPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Mock helper for network operations
function Mock-NetworkOperation {
    [CmdletBinding()]
    param(
        [string]$Command,
        [object]$ReturnValue
    )
    
    Mock $Command { return $ReturnValue }
}

# Helper to create test CSV files
function New-TestCSVFile {
    [CmdletBinding()]
    param(
        [string]$FilePath,
        [array]$Data
    )
    
    $Data | Export-Csv -Path $FilePath -NoTypeInformation
    return $FilePath
}

# Helper to test file operations safely
function Test-FileOperation {
    [CmdletBinding()]
    param(
        [string]$FilePath,
        [string]$ExpectedContent = $null
    )
    
    $result = @{
        Exists = Test-Path $FilePath
        Content = $null
        Size = 0
    }
    
    if ($result.Exists) {
        $result.Content = Get-Content $FilePath -Raw
        $result.Size = (Get-Item $FilePath).Length
    }
    
    if ($ExpectedContent) {
        $result.ContentMatches = $result.Content -eq $ExpectedContent
    }
    
    return $result
}

# Helper to validate PowerShell syntax
function Test-PowerShellSyntax {
    [CmdletBinding()]
    param(
        [string]$ScriptPath
    )
    
    try {
        $null = [System.Management.Automation.Language.Parser]::ParseFile($ScriptPath, [ref]$null, [ref]$null)
        return $true
    } catch {
        return $false
    }
}

# Helper to test cmdlet parameters
function Test-CmdletParameters {
    [CmdletBinding()]
    param(
        [string]$CmdletName,
        [string[]]$ExpectedParameters
    )
    
    $actualParameters = (Get-Command $CmdletName).Parameters.Keys
    $missingParameters = $ExpectedParameters | Where-Object { $_ -notin $actualParameters }
    
    return @{
        HasAllParameters = $missingParameters.Count -eq 0
        MissingParameters = $missingParameters
        ActualParameters = $actualParameters
    }
}

# Helper to create mock system info
function New-MockSystemInfo {
    [CmdletBinding()]
    param()
    
    return @{
        ComputerName = "TEST-COMPUTER"
        OperatingSystem = "Microsoft Windows 10 Pro"
        Version = "10.0.19042"
        TotalPhysicalMemory = 17179869184
        Processor = "Intel(R) Core(TM) i7-8750H CPU @ 2.20GHz"
        Architecture = "64-bit"
        Domain = "WORKGROUP"
        LastBootUpTime = (Get-Date).AddDays(-1)
    }
}

# Helper to create mock network scan results
function New-MockNetworkScanResult {
    [CmdletBinding()]
    param(
        [string]$IPAddress = "192.168.1.1",
        [int[]]$OpenPorts = @(80, 443, 22)
    )
    
    return @{
        IPAddress = $IPAddress
        IsOnline = $true
        OpenPorts = $OpenPorts
        Hostname = "test-host"
        ResponseTime = 50
    }
}

# Helper to create test scheduled task
function New-MockScheduledTask {
    [CmdletBinding()]
    param(
        [string]$TaskName = "TestTask",
        [string]$ScriptPath = "C:\temp\test.ps1"
    )
    
    return @{
        TaskName = $TaskName
        ScriptPath = $ScriptPath
        Trigger = "Daily"
        Time = "09:00"
        User = $env:USERNAME
        Status = "Created"
    }
}

# Export functions for use in tests
Export-ModuleMember -Function *