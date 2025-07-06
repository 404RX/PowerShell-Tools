<#
.SYNOPSIS
    Pester configuration for PowerShell-Tools repository
.DESCRIPTION
    This configuration file sets up Pester testing environment with
    customized settings for the PowerShell-Tools project.
#>

# Pester configuration for PowerShell-Tools
$PesterConfig = @{
    Run = @{
        # Test discovery
        Path = @(
            ".\Tests\Unit",
            ".\Tests\Integration"
        )
        
        # Exit behavior
        Exit = $true
        PassThru = $true
        
        # Execution settings
        Throw = $false
        SkipRemainingOnFailure = 'None'
    }
    
    # Test filtering
    Filter = @{
        # Tags to include/exclude
        # Tag = @()
        # ExcludeTag = @()
        
        # Test names to include/exclude
        # FullName = @()
        # Name = @()
    }
    
    # Code coverage settings
    CodeCoverage = @{
        Enabled = $true
        
        # Files to analyze for coverage
        Path = @(
            ".\System-Administration\*.ps1",
            ".\Network-Management\*.ps1",
            ".\Security\*.ps1",
            ".\Development-Tools\*.ps1",
            ".\Automation\*.ps1"
        )
        
        # Output settings
        OutputFormat = 'JaCoCo'
        OutputPath = '.\TestResults\coverage.xml'
        
        # Coverage thresholds
        CoveragePercentTarget = 80
        
        # Exclude certain functions from coverage
        ExcludeTests = $true
        RecursePaths = $true
    }
    
    # Test result output
    TestResult = @{
        Enabled = $true
        OutputFormat = 'NUnitXml'
        OutputPath = '.\TestResults\test-results.xml'
        TestSuiteName = 'PowerShell-Tools'
    }
    
    # Output and reporting
    Output = @{
        Verbosity = 'Detailed'
        StackTraceVerbosity = 'Filtered'
        CIFormat = 'Auto'
    }
    
    # Should settings
    Should = @{
        ErrorAction = 'Stop'
        WarningAction = 'Continue'
    }
    
    # Debug settings
    Debug = @{
        ShowFullErrors = $true
        WriteDebugMessages = $false
        WriteDebugMessagesFrom = @()
        ShowNavigationMarkers = $false
        ReturnRawResultObject = $false
    }
}

# Export configuration
$PesterConfig