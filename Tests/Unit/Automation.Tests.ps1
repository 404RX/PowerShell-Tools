#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Unit tests for Automation scripts
.DESCRIPTION
    This file contains unit tests for the Schedule-Tasks.ps1 script.
    Tests cover task creation, scheduling, management, and error handling.
#>

BeforeAll {
    # Import the script under test
    $ScriptPath = Join-Path $PSScriptRoot "..\..\Automation\Schedule-Tasks.ps1"
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

Describe "Schedule-Tasks.ps1" {
    Context "Script validation" {
        It "should have valid PowerShell syntax" {
            $ScriptPath = Join-Path $PSScriptRoot "..\..\Automation\Schedule-Tasks.ps1"
            Test-PowerShellSyntax -ScriptPath $ScriptPath | Should -Be $true
        }
        
        It "should be able to get help information" {
            $help = Get-Help New-ScheduledTask -ErrorAction SilentlyContinue
            $help | Should -Not -BeNullOrEmpty
            $help.Synopsis | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Parameter validation" {
        It "should accept valid task names" {
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -WhatIf } | Should -Not -Throw
        }
        
        It "should accept valid script paths" {
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\Scripts\test.ps1" -WhatIf } | Should -Not -Throw
        }
        
        It "should accept valid trigger types" {
            $validTriggers = @('Once', 'Daily', 'Weekly', 'Monthly', 'AtStartup', 'AtLogon')
            foreach ($trigger in $validTriggers) {
                { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -Trigger $trigger -WhatIf } | Should -Not -Throw
            }
        }
        
        It "should accept valid time formats" {
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -Time "09:30" -WhatIf } | Should -Not -Throw
        }
        
        It "should accept valid user accounts" {
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -User "SYSTEM" -WhatIf } | Should -Not -Throw
        }
        
        It "should reject invalid task names" {
            { New-ScheduledTask -TaskName "Invalid*Task" -ScriptPath "C:\test.ps1" -ErrorAction Stop } | Should -Throw
        }
        
        It "should reject invalid time formats" {
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -Time "25:00" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "Task creation functionality" {
        BeforeEach {
            # Mock Windows Task Scheduler cmdlets
            Mock Register-ScheduledTask {
                param($TaskName, $Action, $Trigger, $Principal, $Settings)
                return [PSCustomObject]@{
                    TaskName = $TaskName
                    TaskPath = "\"
                    State = "Ready"
                    Actions = @($Action)
                    Triggers = @($Trigger)
                    Principal = $Principal
                    Settings = $Settings
                }
            }
            
            Mock New-ScheduledTaskAction {
                param($Execute, $Argument)
                return [PSCustomObject]@{
                    Execute = $Execute
                    Arguments = $Argument
                }
            }
            
            Mock New-ScheduledTaskTrigger {
                param($Once, $Daily, $Weekly, $Monthly, $AtStartup, $AtLogon, $At)
                return [PSCustomObject]@{
                    TriggerType = if ($Once) { "Once" } elseif ($Daily) { "Daily" } elseif ($Weekly) { "Weekly" } elseif ($Monthly) { "Monthly" } elseif ($AtStartup) { "AtStartup" } elseif ($AtLogon) { "AtLogon" }
                    StartTime = $At
                }
            }
            
            Mock New-ScheduledTaskPrincipal {
                param($UserId, $RunLevel)
                return [PSCustomObject]@{
                    UserId = $UserId
                    RunLevel = $RunLevel
                }
            }
            
            Mock New-ScheduledTaskSettingsSet {
                return [PSCustomObject]@{
                    AllowStartIfOnBatteries = $true
                    DontStopIfGoingOnBatteries = $true
                    ExecutionTimeLimit = "PT1H"
                }
            }
            
            Mock Test-Path { return $true }  # Simulate script path exists
        }
        
        It "should create task with Once trigger" {
            $result = New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -Trigger "Once" -Time "09:00"
            $result | Should -Not -BeNullOrEmpty
            $result.TaskName | Should -Be "TestTask"
            
            Assert-MockCalled Register-ScheduledTask -Times 1
        }
        
        It "should create task with Daily trigger" {
            $result = New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -Trigger "Daily" -Time "09:00"
            $result | Should -Not -BeNullOrEmpty
            
            Assert-MockCalled New-ScheduledTaskTrigger -ParameterFilter { $Daily -eq $true }
        }
        
        It "should create task with Weekly trigger" {
            $result = New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -Trigger "Weekly" -Time "09:00"
            $result | Should -Not -BeNullOrEmpty
            
            Assert-MockCalled New-ScheduledTaskTrigger -ParameterFilter { $Weekly -eq $true }
        }
        
        It "should create task with Monthly trigger" {
            $result = New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -Trigger "Monthly" -Time "09:00"
            $result | Should -Not -BeNullOrEmpty
            
            Assert-MockCalled New-ScheduledTaskTrigger -ParameterFilter { $Monthly -eq $true }
        }
        
        It "should create task with AtStartup trigger" {
            $result = New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -Trigger "AtStartup"
            $result | Should -Not -BeNullOrEmpty
            
            Assert-MockCalled New-ScheduledTaskTrigger -ParameterFilter { $AtStartup -eq $true }
        }
        
        It "should create task with AtLogon trigger" {
            $result = New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -Trigger "AtLogon"
            $result | Should -Not -BeNullOrEmpty
            
            Assert-MockCalled New-ScheduledTaskTrigger -ParameterFilter { $AtLogon -eq $true }
        }
        
        It "should create task with SYSTEM user" {
            $result = New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -User "SYSTEM"
            $result | Should -Not -BeNullOrEmpty
            
            Assert-MockCalled New-ScheduledTaskPrincipal -ParameterFilter { $UserId -eq "SYSTEM" }
        }
        
        It "should create task with current user" {
            $result = New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1"
            $result | Should -Not -BeNullOrEmpty
            
            Assert-MockCalled New-ScheduledTaskPrincipal -ParameterFilter { $UserId -eq $env:USERNAME }
        }
        
        It "should create task with elevated privileges when needed" {
            $result = New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -RunElevated
            $result | Should -Not -BeNullOrEmpty
            
            Assert-MockCalled New-ScheduledTaskPrincipal -ParameterFilter { $RunLevel -eq "Highest" }
        }
    }
    
    Context "Task management functionality" {
        BeforeEach {
            # Mock task management cmdlets
            Mock Get-ScheduledTask {
                param($TaskName)
                if ($TaskName -eq "ExistingTask") {
                    return [PSCustomObject]@{
                        TaskName = $TaskName
                        TaskPath = "\"
                        State = "Ready"
                    }
                } else {
                    return $null
                }
            }
            
            Mock Start-ScheduledTask {
                param($TaskName)
                return $true
            }
            
            Mock Stop-ScheduledTask {
                param($TaskName)
                return $true
            }
            
            Mock Unregister-ScheduledTask {
                param($TaskName, $Confirm)
                return $true
            }
            
            Mock Enable-ScheduledTask {
                param($TaskName)
                return [PSCustomObject]@{
                    TaskName = $TaskName
                    State = "Ready"
                }
            }
            
            Mock Disable-ScheduledTask {
                param($TaskName)
                return [PSCustomObject]@{
                    TaskName = $TaskName
                    State = "Disabled"
                }
            }
        }
        
        It "should start existing task" {
            $result = Start-Task -TaskName "ExistingTask"
            $result | Should -Be $true
            
            Assert-MockCalled Start-ScheduledTask -ParameterFilter { $TaskName -eq "ExistingTask" }
        }
        
        It "should stop running task" {
            $result = Stop-Task -TaskName "ExistingTask"
            $result | Should -Be $true
            
            Assert-MockCalled Stop-ScheduledTask -ParameterFilter { $TaskName -eq "ExistingTask" }
        }
        
        It "should remove existing task" {
            $result = Remove-Task -TaskName "ExistingTask"
            $result | Should -Be $true
            
            Assert-MockCalled Unregister-ScheduledTask -ParameterFilter { $TaskName -eq "ExistingTask" }
        }
        
        It "should enable disabled task" {
            $result = Enable-Task -TaskName "ExistingTask"
            $result | Should -Not -BeNullOrEmpty
            $result.State | Should -Be "Ready"
            
            Assert-MockCalled Enable-ScheduledTask -ParameterFilter { $TaskName -eq "ExistingTask" }
        }
        
        It "should disable active task" {
            $result = Disable-Task -TaskName "ExistingTask"
            $result | Should -Not -BeNullOrEmpty
            $result.State | Should -Be "Disabled"
            
            Assert-MockCalled Disable-ScheduledTask -ParameterFilter { $TaskName -eq "ExistingTask" }
        }
        
        It "should get task information" {
            $result = Get-Task -TaskName "ExistingTask"
            $result | Should -Not -BeNullOrEmpty
            $result.TaskName | Should -Be "ExistingTask"
            
            Assert-MockCalled Get-ScheduledTask -ParameterFilter { $TaskName -eq "ExistingTask" }
        }
        
        It "should handle non-existent tasks gracefully" {
            $result = Get-Task -TaskName "NonExistentTask"
            $result | Should -BeNullOrEmpty
        }
    }
    
    Context "Security and permissions" {
        It "should validate script path exists" {
            Mock Test-Path { return $false }
            
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\nonexistent.ps1" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle permission errors gracefully" {
            Mock Register-ScheduledTask { throw "Access denied" }
            
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -ErrorAction Stop } | Should -Throw
        }
        
        It "should require confirmation for dangerous operations" {
            Mock Read-Host { return "Y" }
            
            $result = Remove-Task -TaskName "ExistingTask"
            $result | Should -Be $true
            
            Assert-MockCalled Read-Host -Times 1
        }
        
        It "should skip operations when user declines confirmation" {
            Mock Read-Host { return "N" }
            
            $result = Remove-Task -TaskName "ExistingTask"
            $result | Should -Be $false
            
            Assert-MockCalled Unregister-ScheduledTask -Times 0
        }
    }
    
    Context "Error handling" {
        It "should handle task scheduler service errors" {
            Mock Register-ScheduledTask { throw "Task Scheduler service is not available" }
            
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle duplicate task names" {
            Mock Register-ScheduledTask { throw "Task already exists" }
            
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle invalid script paths" {
            Mock Test-Path { return $false }
            
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\invalid\path.ps1" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle permission denied errors" {
            Mock Register-ScheduledTask { throw "UnauthorizedAccessException" }
            
            { New-ScheduledTask -TaskName "TestTask" -ScriptPath "C:\test.ps1" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "Performance and reliability" {
        It "should create tasks quickly" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            1..5 | ForEach-Object { New-ScheduledTask -TaskName "TestTask$_" -ScriptPath "C:\test.ps1" | Out-Null }
            $stopwatch.Stop()
            
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 10000  # 10 seconds for 5 tasks
        }
        
        It "should handle multiple task operations efficiently" {
            $tasks = @("Task1", "Task2", "Task3")
            
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            foreach ($task in $tasks) {
                New-ScheduledTask -TaskName $task -ScriptPath "C:\test.ps1" | Out-Null
                Start-Task -TaskName $task | Out-Null
                Stop-Task -TaskName $task | Out-Null
            }
            $stopwatch.Stop()
            
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 15000  # 15 seconds for 3 tasks with operations
        }
        
        It "should handle concurrent task operations safely" {
            # This test would need to be more complex in a real scenario
            # For now, just verify basic functionality doesn't break
            $result1 = New-ScheduledTask -TaskName "ConcurrentTask1" -ScriptPath "C:\test.ps1"
            $result2 = New-ScheduledTask -TaskName "ConcurrentTask2" -ScriptPath "C:\test.ps1"
            
            $result1 | Should -Not -BeNullOrEmpty
            $result2 | Should -Not -BeNullOrEmpty
        }
    }
}