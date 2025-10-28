<#
    Resolve the script-under-test (SUT) path reliably, regardless of the current working directory.
    This test file lives in:    ...\System-Administration\Tests\
    The SUT lives one level up: ...\System-Administration\Get-OperatingSystemDetails.ps1
#>
$testDir   = $PSScriptRoot
$scriptDir = Split-Path -Parent $testDir
$script:SutPath = Join-Path $scriptDir 'Get-OperatingSystemDetails.ps1'

if (-not (Test-Path -LiteralPath $script:SutPath)) {
    throw "SUT not found at '$script:SutPath'"
}

# Note: In Pester 5, load the SUT inside a BeforeAll block so the function is available in test scope.

Describe Get-OperatingSystemDetails {
    Context "When retrieving operating system details" {

        Mock Get-CimInstance {
            param (
                [string]$ClassName,
                [string[]]$ComputerName
            )
            # Return a mock object with expected properties
            return [PSCustomObject]@{
                CSName               = $ComputerName
                Caption              = "Microsoft Windows 10 Pro"
                Version              = "10.0.19044"
                OSArchitecture       = "64-bit"
                TotalVisibleMemoryGB = 16
                FreePhysicalMemoryGB = 8
            }
        }

        BeforeAll {
            # Avoid interactive confirmation prompts during tests
            $script:OldConfirmPreference = $ConfirmPreference
            $ConfirmPreference = 'None'
            # Recompute SUT path in run scope (Pester 5 isolates discovery and run phases)
            $testDir   = $PSScriptRoot
            if (-not $testDir) { $testDir = Split-Path -Parent $PSCommandPath }
            $scriptDir = Split-Path -Parent $testDir
            $sut       = Join-Path $scriptDir 'Get-OperatingSystemDetails.ps1'
            if (-not (Test-Path -LiteralPath $sut)) {
                throw "SUT not found at '$sut'"
            }
            . $sut
        }

        AfterAll {
            if ($script:OldConfirmPreference) { $ConfirmPreference = $script:OldConfirmPreference }
        }


        #Test 1: Behavior when valid computer name is provided
        It "Accept computer name and retrieve details using Get-CimInstance" {
            # Arrange
            $computerName = "localhost"
            # Act
            $osDetails = Get-OperatingSystemDetails -ComputerName $computerName
            # Assert
            $osDetails | Should -Not -Be $null
            $osDetails.ComputerName | Should -Be $computerName
            $osDetails.OSName | Should -Not -Be $null
            $osDetails.OSVersion | Should -Not -Be $null
            $osDetails.OSArchitecture | Should -Not -Be $null
            $osDetails.TotalVisibleMemoryGB | Should -BeGreaterThan 0
            $osDetails.FreePhysicalMemoryGB | Should -BeGreaterThan 0
        }#Test 1

        #Test 2: Behavior when invalid computer name is provided
        It "should handle errors gracefully" {
            # Arrange
            $invalidComputerName = "InvalidComputerName123"
            # Act & Assert
            { Get-OperatingSystemDetails -ComputerName $invalidComputerName -ErrorAction Stop } | Should -Throw
        }#Test 2

        #Test 3: Behavior when WhatIf parameter is used
        It "should support WhatIf parameter" {
            # Arrange
            $computerName = "localhost"
            # Act
            $whatIfResult = Get-OperatingSystemDetails -ComputerName $computerName -WhatIf
            # Assert
            $whatIfResult | Should -Be $null
        }#Test 3

        #Test 4: Behavior when Verbose and Debug parameters are used
        It "should log verbose and debug information" {
            # Arrange
            $computerName = "localhost"
            # Act
            $osDetails = Get-OperatingSystemDetails -ComputerName $computerName -Verbose -Debug
            # Assert
            $osDetails | Should -Not -Be $null
        }#Test 4

        #Test 5: Behavior when multiple computer names are provided via pipeline
        It "should process multiple computer names" {
            # Arrange
            $computerNames = @("localhost", "RemoteComputer1", "RemoteComputer2")
            # Act
            $results = $computerNames | ForEach-Object { Get-OperatingSystemDetails -ComputerName $_ }
            # Assert
            $results | Should -Not -Be $null
            $results.Count | Should -Be $computerNames.Count
        }#Test 5

        #Test 6: Behavior when multiple computer names are provided via arguments
        It "should process multiple computer names via arguments" {
            # Arrange
            $computerNames = @("localhost", "RemoteComputer1", "RemoteComputer2")
            # Act
            $results = Get-OperatingSystemDetails -ComputerName $computerNames
            # Assert
            $results | Should -Not -Be $null
            $results.Count | Should -Be $computerNames.Count
        }#Test 6

        #Test 7: Behavior when no computer name is provided
        It "should require a computer name" {
            # Act & Assert
            { Get-OperatingSystemDetails -ErrorAction Stop } | Should -Throw
        }#Test 7

        #Test 8: Behavior when provided non string computer name
        It "should validate computer name parameter type" {
            # Act & Assert
            { Get-OperatingSystemDetails -ComputerName 12345 -ErrorAction Stop } | Should -Throw
        }#Test 8

    }
}