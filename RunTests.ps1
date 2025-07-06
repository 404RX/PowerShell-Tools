#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Main test runner for PowerShell-Tools repository
.DESCRIPTION
    This script provides a unified entry point for running all tests in the PowerShell-Tools repository.
    It supports unit tests, integration tests, and generates comprehensive test reports.
.PARAMETER TestType
    Type of tests to run: All, Unit, Integration
.PARAMETER OutputFormat
    Output format for test results: NUnitXml, JUnitXml, Console
.PARAMETER ShowDetails
    Show detailed test output
.PARAMETER CI
    Run in CI mode with stricter settings
.EXAMPLE
    .\RunTests.ps1 -TestType All -OutputFormat Console -ShowDetails
.EXAMPLE
    .\RunTests.ps1 -TestType Unit -OutputFormat NUnitXml -CI
#>

[CmdletBinding()]
param(
    [ValidateSet('All', 'Unit', 'Integration')]
    [string]$TestType = 'All',
    
    [ValidateSet('NUnitXml', 'JUnitXml', 'Console')]
    [string]$OutputFormat = 'Console',
    
    [switch]$ShowDetails,
    
    [switch]$CI
)

# Set error handling
$ErrorActionPreference = 'Stop'

# Import required modules
Write-Host "🔧 Setting up test environment..." -ForegroundColor Cyan

# Check if Pester is installed
if (!(Get-Module -ListAvailable -Name Pester)) {
    Write-Host "❌ Pester is not installed. Installing..." -ForegroundColor Yellow
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
}

# Import Pester
Import-Module Pester -Force

# Set up paths
$RepoRoot = $PSScriptRoot
$TestsPath = Join-Path $RepoRoot "Tests"
$ResultsPath = Join-Path $RepoRoot "TestResults"

# Ensure results directory exists
if (!(Test-Path $ResultsPath)) {
    New-Item -ItemType Directory -Path $ResultsPath -Force | Out-Null
}

# Configure test paths based on TestType
$TestPaths = @()
switch ($TestType) {
    'Unit' { $TestPaths += Join-Path $TestsPath "Unit" }
    'Integration' { $TestPaths += Join-Path $TestsPath "Integration" }
    'All' { 
        $TestPaths += Join-Path $TestsPath "Unit"
        $TestPaths += Join-Path $TestsPath "Integration"
    }
}

# Configure Pester settings
$PesterConfig = @{
    Run = @{
        Path = $TestPaths
        PassThru = $true
    }
    Output = @{
        Verbosity = if ($ShowDetails) { 'Detailed' } else { 'Normal' }
    }
    Should = @{
        ErrorAction = 'Stop'
    }
}

# Add output configuration if not Console
if ($OutputFormat -ne 'Console') {
    $OutputFile = Join-Path $ResultsPath "TestResults-$(Get-Date -Format 'yyyyMMdd-HHmmss').$($OutputFormat.ToLower())"
    $PesterConfig.TestResult = @{
        Enabled = $true
        OutputFormat = $OutputFormat
        OutputPath = $OutputFile
    }
}

# CI-specific settings
if ($CI) {
    $PesterConfig.CodeCoverage = @{
        Enabled = $true
        Path = @(
            Join-Path $RepoRoot "System-Administration\*.ps1"
            Join-Path $RepoRoot "Network-Management\*.ps1"
            Join-Path $RepoRoot "Security\*.ps1"
            Join-Path $RepoRoot "Development-Tools\*.ps1"
            Join-Path $RepoRoot "Automation\*.ps1"
        )
        OutputFormat = 'JaCoCo'
        OutputPath = Join-Path $ResultsPath "coverage.xml"
    }
}

# Run tests
Write-Host "🧪 Running $TestType tests..." -ForegroundColor Green
Write-Host "   Test paths: $($TestPaths -join ', ')" -ForegroundColor Gray

try {
    $Configuration = New-PesterConfiguration -Hashtable $PesterConfig
    $TestResults = Invoke-Pester -Configuration $Configuration
    
    # Display results summary
    Write-Host "`n📊 Test Results Summary:" -ForegroundColor Cyan
    Write-Host "   Total Tests: $($TestResults.TotalCount)" -ForegroundColor White
    Write-Host "   Passed: $($TestResults.PassedCount)" -ForegroundColor Green
    Write-Host "   Failed: $($TestResults.FailedCount)" -ForegroundColor Red
    Write-Host "   Skipped: $($TestResults.SkippedCount)" -ForegroundColor Yellow
    Write-Host "   Duration: $($TestResults.Duration)" -ForegroundColor White
    
    if ($TestResults.CodeCoverage) {
        Write-Host "   Code Coverage: $([math]::Round($TestResults.CodeCoverage.CoveragePercent, 2))%" -ForegroundColor Magenta
    }
    
    # Exit with appropriate code
    if ($TestResults.FailedCount -gt 0) {
        Write-Host "❌ Some tests failed!" -ForegroundColor Red
        exit 1
    } else {
        Write-Host "✅ All tests passed!" -ForegroundColor Green
        exit 0
    }
    
} catch {
    Write-Host "❌ Error running tests: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}