#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Unit tests for Network-Management scripts
.DESCRIPTION
    This file contains unit tests for the Scan-Network.ps1 script.
    Tests cover parameter validation, network scanning functionality, and output format.
#>

BeforeAll {
    # Import the script under test
    $ScriptPath = Join-Path $PSScriptRoot "..\..\Network-Management\Scan-Network.ps1"
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

Describe "Scan-Network.ps1" {
    Context "Script validation" {
        It "should have valid PowerShell syntax" {
            $ScriptPath = Join-Path $PSScriptRoot "..\..\Network-Management\Scan-Network.ps1"
            Test-PowerShellSyntax -ScriptPath $ScriptPath | Should -Be $true
        }
        
        It "should be able to get help information" {
            $help = Get-Help Scan-Network -ErrorAction SilentlyContinue
            $help | Should -Not -BeNullOrEmpty
            $help.Synopsis | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Parameter validation" {
        It "should accept valid IP address" {
            { Scan-Network -IPAddress "192.168.1.1" -WhatIf } | Should -Not -Throw
        }
        
        It "should accept valid subnet" {
            { Scan-Network -Subnet "192.168.1.0/24" -WhatIf } | Should -Not -Throw
        }
        
        It "should accept valid port ranges" {
            { Scan-Network -IPAddress "192.168.1.1" -Ports @(80, 443, 22) -WhatIf } | Should -Not -Throw
        }
        
        It "should accept valid timeout values" {
            { Scan-Network -IPAddress "192.168.1.1" -Timeout 5000 -WhatIf } | Should -Not -Throw
        }
        
        It "should reject invalid IP addresses" {
            { Scan-Network -IPAddress "999.999.999.999" -ErrorAction Stop } | Should -Throw
        }
        
        It "should reject invalid subnet formats" {
            { Scan-Network -Subnet "192.168.1.0/99" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "Network scanning functionality" {
        BeforeEach {
            # Mock network operations for testing
            Mock Test-NetConnection {
                param($ComputerName, $Port, $InformationLevel)
                
                # Simulate different responses based on IP
                switch ($ComputerName) {
                    "192.168.1.1" {
                        return [PSCustomObject]@{
                            ComputerName = $ComputerName
                            RemoteAddress = $ComputerName
                            RemotePort = $Port
                            InterfaceAlias = "Ethernet"
                            SourceAddress = "192.168.1.100"
                            TcpTestSucceeded = $true
                            PingSucceeded = $true
                            PingReplyDetails = @{ RoundtripTime = 10 }
                        }
                    }
                    "192.168.1.2" {
                        return [PSCustomObject]@{
                            ComputerName = $ComputerName
                            RemoteAddress = $ComputerName
                            RemotePort = $Port
                            InterfaceAlias = "Ethernet"
                            SourceAddress = "192.168.1.100"
                            TcpTestSucceeded = $false
                            PingSucceeded = $true
                            PingReplyDetails = @{ RoundtripTime = 15 }
                        }
                    }
                    default {
                        return [PSCustomObject]@{
                            ComputerName = $ComputerName
                            RemoteAddress = $ComputerName
                            RemotePort = $Port
                            InterfaceAlias = "Ethernet"
                            SourceAddress = "192.168.1.100"
                            TcpTestSucceeded = $false
                            PingSucceeded = $false
                            PingReplyDetails = $null
                        }
                    }
                }
            }
            
            Mock Resolve-DnsName {
                param($Name)
                return [PSCustomObject]@{
                    Name = "test-host.local"
                    Type = "A"
                    TTL = 300
                    Section = "Answer"
                    IPAddress = $Name
                }
            }
        }
        
        It "should scan single IP address" {
            $result = Scan-Network -IPAddress "192.168.1.1"
            $result | Should -Not -BeNullOrEmpty
            $result.IPAddress | Should -Be "192.168.1.1"
            $result.IsOnline | Should -Be $true
        }
        
        It "should detect open ports" {
            $result = Scan-Network -IPAddress "192.168.1.1" -Ports @(80, 443)
            $result | Should -Not -BeNullOrEmpty
            $result.OpenPorts | Should -Contain 80
            $result.OpenPorts | Should -Contain 443
        }
        
        It "should handle offline hosts" {
            $result = Scan-Network -IPAddress "192.168.1.254"
            $result | Should -Not -BeNullOrEmpty
            $result.IsOnline | Should -Be $false
        }
        
        It "should scan subnet range" {
            $results = Scan-Network -Subnet "192.168.1.0/30"  # Small subnet for testing
            $results | Should -Not -BeNullOrEmpty
            $results.Count | Should -BeGreaterThan 0
        }
        
        It "should include response time for online hosts" {
            $result = Scan-Network -IPAddress "192.168.1.1"
            $result.ResponseTime | Should -BeGreaterThan 0
        }
        
        It "should resolve hostnames when possible" {
            $result = Scan-Network -IPAddress "192.168.1.1"
            $result.Hostname | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Output format validation" {
        It "should return expected properties" {
            $result = Scan-Network -IPAddress "192.168.1.1"
            $expectedProperties = @(
                'IPAddress', 'IsOnline', 'Hostname', 'ResponseTime', 'OpenPorts'
            )
            
            foreach ($property in $expectedProperties) {
                $result.PSObject.Properties.Name | Should -Contain $property
            }
        }
        
        It "should export to CSV when specified" {
            $testPath = Join-Path $script:TempTestPath "network-scan-test.csv"
            $result = Scan-Network -IPAddress "192.168.1.1" -ExportCSV $testPath
            
            $fileResult = Test-FileOperation -FilePath $testPath
            $fileResult.Exists | Should -Be $true
            $fileResult.Size | Should -BeGreaterThan 0
            
            # Verify CSV content
            $csvContent = Import-Csv $testPath
            $csvContent | Should -Not -BeNullOrEmpty
            $csvContent[0].IPAddress | Should -Be "192.168.1.1"
        }
        
        It "should handle multiple results in CSV export" {
            $testPath = Join-Path $script:TempTestPath "network-scan-multi-test.csv"
            $results = Scan-Network -Subnet "192.168.1.0/30" -ExportCSV $testPath
            
            $csvContent = Import-Csv $testPath
            $csvContent.Count | Should -BeGreaterThan 1
        }
    }
    
    Context "Error handling" {
        It "should handle network timeouts gracefully" {
            Mock Test-NetConnection { throw "Timeout" }
            
            { Scan-Network -IPAddress "192.168.1.1" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle DNS resolution failures" {
            Mock Resolve-DnsName { throw "DNS resolution failed" }
            
            # Should not throw, just return empty hostname
            $result = Scan-Network -IPAddress "192.168.1.1"
            $result.Hostname | Should -BeNullOrEmpty
        }
        
        It "should handle invalid CSV export path" {
            Mock Export-Csv { throw "Path not found" }
            
            { Scan-Network -IPAddress "192.168.1.1" -ExportCSV "Z:\invalid\path.csv" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "Performance and reliability" {
        It "should complete single host scan within reasonable time" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            Scan-Network -IPAddress "192.168.1.1" | Out-Null
            $stopwatch.Stop()
            
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 10000  # 10 seconds max
        }
        
        It "should handle concurrent scans efficiently" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            Scan-Network -Subnet "192.168.1.0/30" | Out-Null
            $stopwatch.Stop()
            
            # Should be faster than scanning each IP individually
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 20000  # 20 seconds max
        }
        
        It "should respect timeout parameter" {
            $timeout = 1000  # 1 second
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            Scan-Network -IPAddress "192.168.1.254" -Timeout $timeout | Out-Null
            $stopwatch.Stop()
            
            # Should timeout close to specified value (allow some overhead)
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan ($timeout + 2000)
        }
    }
}