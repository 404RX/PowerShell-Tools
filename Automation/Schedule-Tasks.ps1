<#
.SYNOPSIS
    A PowerShell script for scheduling and managing automated tasks.

.DESCRIPTION
    This script provides functionality to create, list, modify, and delete scheduled tasks
    on Windows systems. It offers a simplified interface for common task scheduling operations.

.PARAMETER Action
    The action to perform: Create, List, Modify, Delete, or Enable/Disable.

.PARAMETER TaskName
    The name of the scheduled task.

.PARAMETER ScriptPath
    The path to the script or executable to run as the scheduled task.

.PARAMETER Arguments
    The arguments to pass to the script or executable.

.PARAMETER Schedule
    The schedule for the task (Daily, Weekly, Monthly, Once, AtStartup, AtLogon).

.PARAMETER StartTime
    The time to start the task (format: HH:mm).

.PARAMETER DaysOfWeek
    The days of the week to run the task (for Weekly schedule).

.PARAMETER DayOfMonth
    The day of the month to run the task (for Monthly schedule).

.PARAMETER User
    The user account to run the task as. Default is the current user.

.PARAMETER RunWithHighestPrivileges
    Whether to run the task with highest privileges.

.EXAMPLE
    .\Schedule-Tasks.ps1 -Action Create -TaskName "DailyBackup" -ScriptPath "C:\Scripts\Backup.ps1" -Schedule Daily -StartTime "22:00"
    Creates a daily scheduled task that runs at 10:00 PM.

.EXAMPLE
    .\Schedule-Tasks.ps1 -Action List
    Lists all scheduled tasks on the system.

.EXAMPLE
    .\Schedule-Tasks.ps1 -Action Delete -TaskName "DailyBackup"
    Deletes the specified scheduled task.

.NOTES
    Author: Corey Miller
    Date: April 6, 2025
    Requires: PowerShell 5.1 or later
    Requires: Administrator privileges for some operations
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Create", "List", "Modify", "Delete", "Enable", "Disable")]
    [string]$Action,
    
    [Parameter()]
    [string]$TaskName,
    
    [Parameter()]
    [string]$ScriptPath,
    
    [Parameter()]
    [string]$Arguments,
    
    [Parameter()]
    [ValidateSet("Daily", "Weekly", "Monthly", "Once", "AtStartup", "AtLogon")]
    [string]$Schedule,
    
    [Parameter()]
    [string]$StartTime,
    
    [Parameter()]
    [ValidateSet("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")]
    [string[]]$DaysOfWeek,
    
    [Parameter()]
    [ValidateRange(1, 31)]
    [int]$DayOfMonth,
    
    [Parameter()]
    [string]$User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
    
    [Parameter()]
    [switch]$RunWithHighestPrivileges
)

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $isAdmin
}

# Function to create a scheduled task
function New-ScheduledTaskConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TaskName,
        
        [Parameter(Mandatory = $true)]
        [string]$ScriptPath,
        
        [Parameter()]
        [string]$Arguments,
        
        [Parameter(Mandatory = $true)]
        [string]$Schedule,
        
        [Parameter()]
        [string]$StartTime,
        
        [Parameter()]
        [string[]]$DaysOfWeek,
        
        [Parameter()]
        [int]$DayOfMonth,
        
        [Parameter()]
        [string]$User,
        
        [Parameter()]
        [bool]$RunWithHighestPrivileges
    )
    
    # Validate script path
    if (-not (Test-Path $ScriptPath)) {
        throw "Script path does not exist: $ScriptPath"
    }
    
    # Create action
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$ScriptPath`" $Arguments"
    
    # Create trigger based on schedule
    switch ($Schedule) {
        "Daily" {
            if (-not $StartTime) {
                $StartTime = "12:00" # Default to noon
            }
            $trigger = New-ScheduledTaskTrigger -Daily -At $StartTime
        }
        "Weekly" {
            if (-not $StartTime) {
                $StartTime = "12:00" # Default to noon
            }
            if (-not $DaysOfWeek -or $DaysOfWeek.Count -eq 0) {
                $DaysOfWeek = @("Monday") # Default to Monday
            }
            $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DaysOfWeek -At $StartTime
        }
        "Monthly" {
            if (-not $StartTime) {
                $StartTime = "12:00" # Default to noon
            }
            if ($DayOfMonth -lt 1 -or $DayOfMonth -gt 31) {
                $DayOfMonth = 1 # Default to 1st day of month
            }
            $trigger = New-ScheduledTaskTrigger -Monthly -DaysOfMonth $DayOfMonth -At $StartTime
        }
        "Once" {
            if (-not $StartTime) {
                $StartTime = (Get-Date).AddMinutes(5).ToString("HH:mm") # Default to 5 minutes from now
            }
            $trigger = New-ScheduledTaskTrigger -Once -At $StartTime
        }
        "AtStartup" {
            $trigger = New-ScheduledTaskTrigger -AtStartup
        }
        "AtLogon" {
            $trigger = New-ScheduledTaskTrigger -AtLogon -User $User
        }
    }
    
    # Create principal (user context)
    $principal = New-ScheduledTaskPrincipal -UserId $User -LogonType S4U
    
    if ($RunWithHighestPrivileges) {
        $principal = New-ScheduledTaskPrincipal -UserId $User -LogonType S4U -RunLevel Highest
    }
    
    # Create settings
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    # Return task configuration
    return @{
        Action = $action
        Trigger = $trigger
        Principal = $principal
        Settings = $settings
        TaskName = $TaskName
    }
}

# Function to create a scheduled task
function New-CustomScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$TaskConfig
    )
    
    try {
        # Check if task already exists
        $existingTask = Get-ScheduledTask -TaskName $TaskConfig.TaskName -ErrorAction SilentlyContinue
        
        if ($existingTask) {
            Write-Warning "Task '$($TaskConfig.TaskName)' already exists. Use the Modify action to update it."
            return $false
        }
        
        # Register the task
        $task = Register-ScheduledTask -TaskName $TaskConfig.TaskName `
                                      -Action $TaskConfig.Action `
                                      -Trigger $TaskConfig.Trigger `
                                      -Principal $TaskConfig.Principal `
                                      -Settings $TaskConfig.Settings
        
        Write-Host "Task '$($TaskConfig.TaskName)' created successfully." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to create task: $_"
        return $false
    }
}

# Function to modify a scheduled task
function Set-CustomScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$TaskConfig
    )
    
    try {
        # Check if task exists
        $existingTask = Get-ScheduledTask -TaskName $TaskConfig.TaskName -ErrorAction SilentlyContinue
        
        if (-not $existingTask) {
            Write-Warning "Task '$($TaskConfig.TaskName)' does not exist. Use the Create action to create it."
            return $false
        }
        
        # Update the task
        $task = Set-ScheduledTask -TaskName $TaskConfig.TaskName `
                                 -Action $TaskConfig.Action `
                                 -Trigger $TaskConfig.Trigger `
                                 -Principal $TaskConfig.Principal `
                                 -Settings $TaskConfig.Settings
        
        Write-Host "Task '$($TaskConfig.TaskName)' updated successfully." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to update task: $_"
        return $false
    }
}

# Function to list scheduled tasks
function Get-CustomScheduledTasks {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]$TaskName
    )
    
    try {
        if ($TaskName) {
            $tasks = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
            
            if (-not $tasks) {
                Write-Warning "Task '$TaskName' not found."
                return
            }
        }
        else {
            $tasks = Get-ScheduledTask
        }
        
        $taskDetails = @()
        
        foreach ($task in $tasks) {
            $taskInfo = Get-ScheduledTaskInfo -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue
            
            $details = [PSCustomObject]@{
                Name = $task.TaskName
                Path = $task.TaskPath
                State = $task.State
                LastRunTime = $taskInfo.LastRunTime
                LastResult = $taskInfo.LastTaskResult
                NextRunTime = $taskInfo.NextRunTime
                Author = $task.Author
                Description = $task.Description
            }
            
            $taskDetails += $details
        }
        
        return $taskDetails
    }
    catch {
        Write-Error "Failed to list tasks: $_"
        return $null
    }
}

# Function to delete a scheduled task
function Remove-CustomScheduledTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TaskName
    )
    
    try {
        # Check if task exists
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        
        if (-not $existingTask) {
            Write-Warning "Task '$TaskName' does not exist."
            return $false
        }
        
        # Confirm deletion
        $confirmation = Read-Host "Are you sure you want to delete task '$TaskName'? (Y/N)"
        
        if ($confirmation -ne "Y" -and $confirmation -ne "y") {
            Write-Host "Task deletion cancelled." -ForegroundColor Yellow
            return $false
        }
        
        # Delete the task
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        
        Write-Host "Task '$TaskName' deleted successfully." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to delete task: $_"
        return $false
    }
}

# Function to enable or disable a scheduled task
function Set-CustomScheduledTaskState {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$TaskName,
        
        [Parameter(Mandatory = $true)]
        [ValidateSet("Enable", "Disable")]
        [string]$State
    )
    
    try {
        # Check if task exists
        $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
        
        if (-not $existingTask) {
            Write-Warning "Task '$TaskName' does not exist."
            return $false
        }
        
        # Enable or disable the task
        if ($State -eq "Enable") {
            Enable-ScheduledTask -TaskName $TaskName
            Write-Host "Task '$TaskName' enabled successfully." -ForegroundColor Green
        }
        else {
            Disable-ScheduledTask -TaskName $TaskName
            Write-Host "Task '$TaskName' disabled successfully." -ForegroundColor Green
        }
        
        return $true
    }
    catch {
        Write-Error "Failed to $($State.ToLower()) task: $_"
        return $false
    }
}

# Main execution
try {
    # Check if running as administrator for certain actions
    $isAdmin = Test-Administrator
    
    if (-not $isAdmin -and ($Action -eq "Create" -or $Action -eq "Modify" -or $Action -eq "Delete" -or $Action -eq "Enable" -or $Action -eq "Disable")) {
        Write-Warning "Some task scheduler operations require administrator privileges. You may encounter permission errors."
    }
    
    # Execute the requested action
    switch ($Action) {
        "Create" {
            if (-not $TaskName) {
                throw "TaskName parameter is required for the Create action."
            }
            
            if (-not $ScriptPath) {
                throw "ScriptPath parameter is required for the Create action."
            }
            
            if (-not $Schedule) {
                throw "Schedule parameter is required for the Create action."
            }
            
            $taskConfig = New-ScheduledTaskConfig -TaskName $TaskName `
                                                 -ScriptPath $ScriptPath `
                                                 -Arguments $Arguments `
                                                 -Schedule $Schedule `
                                                 -StartTime $StartTime `
                                                 -DaysOfWeek $DaysOfWeek `
                                                 -DayOfMonth $DayOfMonth `
                                                 -User $User `
                                                 -RunWithHighestPrivileges $RunWithHighestPrivileges
            
            New-CustomScheduledTask -TaskConfig $taskConfig
        }
        
        "List" {
            $tasks = Get-CustomScheduledTasks -TaskName $TaskName
            
            if ($tasks) {
                $tasks | Format-Table -AutoSize
            }
        }
        
        "Modify" {
            if (-not $TaskName) {
                throw "TaskName parameter is required for the Modify action."
            }
            
            if (-not $ScriptPath) {
                throw "ScriptPath parameter is required for the Modify action."
            }
            
            if (-not $Schedule) {
                throw "Schedule parameter is required for the Modify action."
            }
            
            $taskConfig = New-ScheduledTaskConfig -TaskName $TaskName `
                                                 -ScriptPath $ScriptPath `
                                                 -Arguments $Arguments `
                                                 -Schedule $Schedule `
                                                 -StartTime $StartTime `
                                                 -DaysOfWeek $DaysOfWeek `
                                                 -DayOfMonth $DayOfMonth `
                                                 -User $User `
                                                 -RunWithHighestPrivileges $RunWithHighestPrivileges
            
            Set-CustomScheduledTask -TaskConfig $taskConfig
        }
        
        "Delete" {
            if (-not $TaskName) {
                throw "TaskName parameter is required for the Delete action."
            }
            
            Remove-CustomScheduledTask -TaskName $TaskName
        }
        
        "Enable" {
            if (-not $TaskName) {
                throw "TaskName parameter is required for the Enable action."
            }
            
            Set-CustomScheduledTaskState -TaskName $TaskName -State "Enable"
        }
        
        "Disable" {
            if (-not $TaskName) {
                throw "TaskName parameter is required for the Disable action."
            }
            
            Set-CustomScheduledTaskState -TaskName $TaskName -State "Disable"
        }
    }
}
catch {
    Write-Error "Error: $_"
    exit 1
}
