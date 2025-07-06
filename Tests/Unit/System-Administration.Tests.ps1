#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Unit tests for System-Administration scripts
.DESCRIPTION
    This file contains unit tests for the Get-SystemInfo.ps1 script.
    Tests cover parameter validation, output format, and core functionality.
#>

BeforeAll {
    # Import the script under test
    $ScriptPath = Join-Path $PSScriptRoot "..\..\System-Administration\Get-SystemInfo.ps1"
    . $ScriptPath
    
    # Import test helpers
    $TestHelpersPath = Join-Path $PSScriptRoot "..\TestHelpers\TestSetup.ps1"
    . $TestHelpersPath
    
    # Initialize test environment
    Initialize-TestEnvironment
}

AfterAll {
    # Clean up test environment
    Clear-TestEnvironment
}

Describe "Get-SystemInfo.ps1" {
    Context "Script validation" {
        It "should have valid PowerShell syntax" {
            $ScriptPath = Join-Path $PSScriptRoot "..\..\System-Administration\Get-SystemInfo.ps1"
            Test-PowerShellSyntax -ScriptPath $ScriptPath | Should -Be $true
        }
        
        It "should be able to get help information" {
            $help = Get-Help Get-SystemInfo -ErrorAction SilentlyContinue
            $help | Should -Not -BeNullOrEmpty
            $help.Synopsis | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Parameter validation" {
        It "should accept valid computer names" {
            { Get-SystemInfo -ComputerName "localhost" -WhatIf } | Should -Not -Throw
        }
        
        It "should accept array of computer names" {
            { Get-SystemInfo -ComputerName @("localhost", "127.0.0.1") -WhatIf } | Should -Not -Throw
        }
        
        It "should accept valid output path for CSV" {
            $testPath = Join-Path $script:TempTestPath "test-output.csv"
            { Get-SystemInfo -ComputerName "localhost" -ExportCSV $testPath -WhatIf } | Should -Not -Throw
        }
    }
    
    Context "Output format validation" {
        BeforeEach {
            # Mock CIM cmdlets for testing
            Mock Get-CimInstance {
                switch ($ClassName) {
                    'Win32_ComputerSystem' {
                        return [PSCustomObject]@{
                            Name = "TEST-COMPUTER"
                            Domain = "WORKGROUP"
                            TotalPhysicalMemory = 17179869184
                            Manufacturer = "Dell Inc."
                            Model = "Inspiron 5570"
                        }
                    }
                    'Win32_OperatingSystem' {
                        return [PSCustomObject]@{
                            Caption = "Microsoft Windows 10 Pro"
                            Version = "10.0.19042"
                            OSArchitecture = "64-bit"
                            LastBootUpTime = (Get-Date).AddDays(-1)
                            FreePhysicalMemory = 8589934592
                            TotalVisibleMemorySize = 16777216
                        }
                    }
                    'Win32_Processor' {
                        return [PSCustomObject]@{
                            Name = "Intel(R) Core(TM) i7-8750H CPU @ 2.20GHz"
                            NumberOfCores = 6
                            NumberOfLogicalProcessors = 12
                            MaxClockSpeed = 2208
                        }
                    }
                    'Win32_LogicalDisk' {
                        return @(
                            [PSCustomObject]@{
                                DeviceID = "C:"
                                Size = 1000000000000
                                FreeSpace = 500000000000
                                FileSystem = "NTFS"
                                DriveType = 3
                            }
                        )
                    }
                    'Win32_NetworkAdapter' {
                        return @(
                            [PSCustomObject]@{
                                Name = "Ethernet"
                                MACAddress = "00:11:22:33:44:55"
                                AdapterType = "Ethernet 802.3"
                                Speed = 1000000000
                                NetEnabled = $true
                            }
                        )
                    }
                    'Win32_Product' {
                        return @(
                            [PSCustomObject]@{
                                Name = "Microsoft Office"
                                Version = "16.0.13929.20296"
                                Vendor = "Microsoft Corporation"
                            }
                        )
                    }
                    default {
                        return $null
                    }
                }
            }
        }
        
        It "should return system information object" {
            $result = Get-SystemInfo -ComputerName "localhost"
            $result | Should -Not -BeNullOrEmpty
            $result.ComputerName | Should -Be "TEST-COMPUTER"
            $result.OperatingSystem | Should -Be "Microsoft Windows 10 Pro"
        }
        
        It "should include all expected properties" {
            $result = Get-SystemInfo -ComputerName "localhost"
            $expectedProperties = @(
                'ComputerName', 'OperatingSystem', 'Version', 'Architecture',
                'Domain', 'TotalMemoryGB', 'FreeMemoryGB', 'Processor',
                'NumberOfCores', 'LogicalProcessors', 'Disks', 'NetworkAdapters',
                'InstalledSoftware', 'LastBootTime', 'Uptime'
            )
            
            foreach ($property in $expectedProperties) {
                $result.PSObject.Properties.Name | Should -Contain $property
            }
        }
        
        It "should export to CSV when specified" {
            $testPath = Join-Path $script:TempTestPath "system-info-test.csv"
            $result = Get-SystemInfo -ComputerName "localhost" -ExportCSV $testPath
            
            $fileResult = Test-FileOperation -FilePath $testPath
            $fileResult.Exists | Should -Be $true
            $fileResult.Size | Should -BeGreaterThan 0
            
            # Verify CSV content
            $csvContent = Import-Csv $testPath
            $csvContent | Should -Not -BeNullOrEmpty
            $csvContent[0].ComputerName | Should -Be "TEST-COMPUTER"
        }
    }
    
    Context "Error handling" {
        It "should handle invalid computer names gracefully" {
            Mock Get-CimInstance { throw "Computer not found" }
            
            { Get-SystemInfo -ComputerName "invalid-computer" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle CIM connection errors" {
            Mock Get-CimInstance { throw "Access denied" }
            
            { Get-SystemInfo -ComputerName "localhost" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle invalid CSV path" {
            Mock Export-Csv { throw "Path not found" }
            
            { Get-SystemInfo -ComputerName "localhost" -ExportCSV "Z:\invalid\path.csv" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "Performance and reliability" {
        It "should complete within reasonable time" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            Get-SystemInfo -ComputerName "localhost" | Out-Null
            $stopwatch.Stop()
            
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 30000  # 30 seconds max
        }
        
        It "should handle multiple computers" {
            $computers = @("localhost", "127.0.0.1")
            $results = Get-SystemInfo -ComputerName $computers
            
            $results | Should -Not -BeNullOrEmpty
            $results.Count | Should -Be 2
        }
    }
}