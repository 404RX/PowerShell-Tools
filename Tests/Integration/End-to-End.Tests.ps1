#!/usr/bin/env pwsh
<#
.SYNOPSIS
    End-to-end integration tests for PowerShell-Tools
.DESCRIPTION
    This file contains integration tests that verify the complete functionality
    of scripts working together in realistic scenarios.
#>

BeforeAll {
    # Import test helpers
    $TestHelpersPath = Join-Path $PSScriptRoot "..\TestHelpers\TestSetup.ps1"
    . $TestHelpersPath
    
    # Initialize test environment
    Initialize-TestEnvironment
    
    # Define paths to actual scripts
    $script:SystemInfoScript = Join-Path $PSScriptRoot "..\..\System-Administration\Get-SystemInfo.ps1"
    $script:NetworkScanScript = Join-Path $PSScriptRoot "..\..\Network-Management\Scan-Network.ps1"
    $script:PasswordManagerScript = Join-Path $PSScriptRoot "..\..\Security\Password-Manager.ps1"
    $script:CodeGeneratorScript = Join-Path $PSScriptRoot "..\..\Development-Tools\Generate-Code.ps1"
    $script:TaskSchedulerScript = Join-Path $PSScriptRoot "..\..\Automation\Schedule-Tasks.ps1"
}

AfterAll {
    # Clean up test environment
    Clear-TestEnvironment
}

Describe "End-to-End Integration Tests" {
    Context "Cross-script functionality" {
        It "should run all scripts without syntax errors" {
            $scripts = @(
                $script:SystemInfoScript,
                $script:NetworkScanScript,
                $script:PasswordManagerScript,
                $script:CodeGeneratorScript,
                $script:TaskSchedulerScript
            )
            
            foreach ($script in $scripts) {
                { . $script } | Should -Not -Throw
            }
        }
        
        It "should generate system report and schedule task to run it" {
            # Mock the necessary cmdlets for this integration test
            Mock Get-CimInstance {
                return [PSCustomObject]@{
                    Name = "TEST-COMPUTER"
                    Caption = "Microsoft Windows 10 Pro"
                    Version = "10.0.19042"
                }
            }
            
            Mock Register-ScheduledTask {
                return [PSCustomObject]@{
                    TaskName = "SystemReportTask"
                    State = "Ready"
                }
            }
            
            Mock New-ScheduledTaskAction { return @{} }
            Mock New-ScheduledTaskTrigger { return @{} }
            Mock New-ScheduledTaskPrincipal { return @{} }
            Mock New-ScheduledTaskSettingsSet { return @{} }
            Mock Test-Path { return $true }
            
            # Import both scripts
            . $script:SystemInfoScript
            . $script:TaskSchedulerScript
            
            # Create a system report
            $systemInfo = Get-SystemInfo -ComputerName "localhost"
            $systemInfo | Should -Not -BeNullOrEmpty
            
            # Schedule a task to run the system info script
            $task = New-ScheduledTask -TaskName "SystemReportTask" -ScriptPath $script:SystemInfoScript -Trigger "Daily" -Time "09:00"
            $task | Should -Not -BeNullOrEmpty
            $task.TaskName | Should -Be "SystemReportTask"
        }
        
        It "should generate network scan report and create secure password for network device" {
            # Mock network and security functions
            Mock Test-NetConnection {
                return [PSCustomObject]@{
                    ComputerName = "192.168.1.1"
                    TcpTestSucceeded = $true
                    PingSucceeded = $true
                    PingReplyDetails = @{ RoundtripTime = 10 }
                }
            }
            
            Mock ConvertTo-SecureString { return [System.Security.SecureString]::new() }
            Mock ConvertFrom-SecureString { return "MockEncryptedPassword" }
            Mock Export-Clixml { return $true }
            Mock Test-Path { return $false }
            
            # Import both scripts
            . $script:NetworkScanScript
            . $script:PasswordManagerScript
            
            # Scan network
            $networkResults = Scan-Network -IPAddress "192.168.1.1"
            $networkResults | Should -Not -BeNullOrEmpty
            
            # Generate password for discovered device
            $password = New-SecurePassword -Length 16 -IncludeSpecialChars
            $password | Should -Not -BeNullOrEmpty
            $password.Length | Should -Be 16
            
            # Store password for the device
            $result = Set-StoredPassword -Site "Router-192.168.1.1" -Password $password
            $result | Should -Be $true
        }
        
        It "should generate test code and create scheduled task to run tests" {
            # Mock code generation and task scheduling
            Mock New-Item {
                return [PSCustomObject]@{
                    FullName = "TestScript.Tests.ps1"
                    Name = "TestScript.Tests.ps1"
                }
            }
            
            Mock Register-ScheduledTask {
                return [PSCustomObject]@{
                    TaskName = "RunTestsTask"
                    State = "Ready"
                }
            }
            
            Mock New-ScheduledTaskAction { return @{} }
            Mock New-ScheduledTaskTrigger { return @{} }
            Mock New-ScheduledTaskPrincipal { return @{} }
            Mock New-ScheduledTaskSettingsSet { return @{} }
            Mock Test-Path { return $true }
            
            # Import both scripts
            . $script:CodeGeneratorScript
            . $script:TaskSchedulerScript
            
            # Generate test code
            $testFile = New-CodeTemplate -Type "Test" -Name "SystemTests" -Language "PowerShell"
            $testFile | Should -Not -BeNullOrEmpty
            
            # Schedule task to run the tests
            $task = New-ScheduledTask -TaskName "RunTestsTask" -ScriptPath "C:\Scripts\Run-Tests.ps1" -Trigger "Daily" -Time "02:00"
            $task | Should -Not -BeNullOrEmpty
            $task.TaskName | Should -Be "RunTestsTask"
        }
    }
    
    Context "Realistic workflow scenarios" {
        It "should complete a complete system audit workflow" {
            # Mock all necessary cmdlets
            Mock Get-CimInstance {
                switch ($ClassName) {
                    'Win32_ComputerSystem' { return [PSCustomObject]@{ Name = "TEST-COMPUTER"; TotalPhysicalMemory = 16GB } }
                    'Win32_OperatingSystem' { return [PSCustomObject]@{ Caption = "Windows 10"; Version = "10.0.19042" } }
                    default { return [PSCustomObject]@{} }
                }
            }
            
            Mock Test-NetConnection {
                return [PSCustomObject]@{
                    ComputerName = "192.168.1.1"
                    TcpTestSucceeded = $true
                    PingSucceeded = $true
                }
            }
            
            Mock Export-Csv { return $true }
            Mock Test-Path { return $true }
            
            # Import scripts
            . $script:SystemInfoScript
            . $script:NetworkScanScript
            
            # Step 1: Get system information
            $systemInfo = Get-SystemInfo -ComputerName "localhost"
            $systemInfo | Should -Not -BeNullOrEmpty
            
            # Step 2: Scan local network
            $networkScan = Scan-Network -Subnet "192.168.1.0/24"
            $networkScan | Should -Not -BeNullOrEmpty
            
            # Step 3: Export both reports
            $systemReportPath = Join-Path $script:TempTestPath "system-audit.csv"
            $networkReportPath = Join-Path $script:TempTestPath "network-audit.csv"
            
            $systemInfo | Export-Csv -Path $systemReportPath -NoTypeInformation
            $networkScan | Export-Csv -Path $networkReportPath -NoTypeInformation
            
            # Verify both reports were created
            Assert-MockCalled Export-Csv -Exactly 2
        }
        
        It "should complete a development setup workflow" {
            # Mock file operations
            Mock New-Item {
                return [PSCustomObject]@{
                    FullName = "TestProject.ps1"
                    Name = "TestProject.ps1"
                }
            }
            
            Mock ConvertTo-SecureString { return [System.Security.SecureString]::new() }
            Mock Export-Clixml { return $true }
            Mock Test-Path { return $false }
            
            # Import scripts
            . $script:CodeGeneratorScript
            . $script:PasswordManagerScript
            
            # Step 1: Generate project template
            $projectFile = New-CodeTemplate -Type "Script" -Name "DeploymentScript" -Language "PowerShell"
            $projectFile | Should -Not -BeNullOrEmpty
            
            # Step 2: Generate secure API key
            $apiKey = New-SecurePassword -Length 32 -IncludeUppercase -IncludeLowercase -IncludeNumbers
            $apiKey | Should -Not -BeNullOrEmpty
            $apiKey.Length | Should -Be 32
            
            # Step 3: Store API key securely
            $result = Set-StoredPassword -Site "DeploymentAPI" -Password $apiKey
            $result | Should -Be $true
            
            # Verify all operations completed successfully
            Assert-MockCalled New-Item -Times 1
            Assert-MockCalled Export-Clixml -Times 1
        }
    }
    
    Context "Error handling across scripts" {
        It "should handle cascading errors gracefully" {
            # Mock error conditions
            Mock Get-CimInstance { throw "WMI service unavailable" }
            Mock Test-NetConnection { throw "Network unreachable" }
            
            # Import scripts
            . $script:SystemInfoScript
            . $script:NetworkScanScript
            
            # Both operations should fail but not crash
            { Get-SystemInfo -ComputerName "localhost" -ErrorAction Stop } | Should -Throw
            { Scan-Network -IPAddress "192.168.1.1" -ErrorAction Stop } | Should -Throw
        }
        
        It "should maintain data integrity during partial failures" {
            # Mock partial success scenario
            Mock Get-CimInstance {
                if ($ClassName -eq 'Win32_ComputerSystem') {
                    return [PSCustomObject]@{ Name = "TEST-COMPUTER" }
                } else {
                    throw "Access denied"
                }
            }
            
            Mock Test-Path { return $true }
            
            # Import script
            . $script:SystemInfoScript
            
            # Should get some data but handle errors for other parts
            { Get-SystemInfo -ComputerName "localhost" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "Performance integration" {
        It "should handle multiple concurrent operations efficiently" {
            # Mock quick responses
            Mock Get-CimInstance {
                Start-Sleep -Milliseconds 100
                return [PSCustomObject]@{ Name = "TEST-COMPUTER" }
            }
            
            Mock Test-NetConnection {
                Start-Sleep -Milliseconds 50
                return [PSCustomObject]@{
                    ComputerName = "192.168.1.1"
                    TcpTestSucceeded = $true
                    PingSucceeded = $true
                }
            }
            
            Mock Test-Path { return $true }
            
            # Import scripts
            . $script:SystemInfoScript
            . $script:NetworkScanScript
            
            # Run concurrent operations
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            
            $jobs = @(
                Start-Job -ScriptBlock { Get-SystemInfo -ComputerName "localhost" }
                Start-Job -ScriptBlock { Scan-Network -IPAddress "192.168.1.1" }
            )
            
            $results = $jobs | Wait-Job | Receive-Job
            $jobs | Remove-Job
            
            $stopwatch.Stop()
            
            # Should complete both operations in reasonable time
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 5000
            $results.Count | Should -Be 2
        }
    }
}