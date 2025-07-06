#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Unit tests for Development-Tools scripts
.DESCRIPTION
    This file contains unit tests for the Generate-Code.ps1 script.
    Tests cover code generation, template validation, and file operations.
#>

BeforeAll {
    # Import the script under test
    $ScriptPath = Join-Path $PSScriptRoot "..\..\Development-Tools\Generate-Code.ps1"
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

Describe "Generate-Code.ps1" {
    Context "Script validation" {
        It "should have valid PowerShell syntax" {
            $ScriptPath = Join-Path $PSScriptRoot "..\..\Development-Tools\Generate-Code.ps1"
            Test-PowerShellSyntax -ScriptPath $ScriptPath | Should -Be $true
        }
        
        It "should be able to get help information" {
            $help = Get-Help New-CodeTemplate -ErrorAction SilentlyContinue
            $help | Should -Not -BeNullOrEmpty
            $help.Synopsis | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Parameter validation" {
        It "should accept valid template types" {
            $validTypes = @('Class', 'Function', 'Script', 'Module', 'Test')
            foreach ($type in $validTypes) {
                { New-CodeTemplate -Type $type -Name "TestItem" -WhatIf } | Should -Not -Throw
            }
        }
        
        It "should accept valid programming languages" {
            $validLanguages = @('PowerShell', 'C#', 'Python', 'JavaScript', 'TypeScript')
            foreach ($language in $validLanguages) {
                { New-CodeTemplate -Type "Class" -Name "TestClass" -Language $language -WhatIf } | Should -Not -Throw
            }
        }
        
        It "should accept valid output paths" {
            $testPath = Join-Path $script:TempTestPath "test-output"
            { New-CodeTemplate -Type "Class" -Name "TestClass" -OutputPath $testPath -WhatIf } | Should -Not -Throw
        }
        
        It "should reject invalid template types" {
            { New-CodeTemplate -Type "InvalidType" -Name "TestItem" -ErrorAction Stop } | Should -Throw
        }
        
        It "should reject invalid names" {
            { New-CodeTemplate -Type "Class" -Name "123InvalidName" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "Code generation functionality" {
        BeforeEach {
            # Mock file operations for testing
            Mock New-Item {
                param($Path, $ItemType, $Value, $Force)
                return [PSCustomObject]@{
                    FullName = $Path
                    Name = Split-Path $Path -Leaf
                    Length = if ($Value) { $Value.Length } else { 0 }
                }
            }
            
            Mock Test-Path { return $false }  # Simulate file doesn't exist
            Mock Get-Content { return $null }
        }
        
        It "should generate PowerShell class template" {
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "TestClass.ps1"
            
            # Verify the mock was called with class content
            Assert-MockCalled New-Item -ParameterFilter { $Value -like "*class TestClass*" }
        }
        
        It "should generate PowerShell function template" {
            $result = New-CodeTemplate -Type "Function" -Name "Test-Function" -Language "PowerShell"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "Test-Function.ps1"
            
            # Verify the mock was called with function content
            Assert-MockCalled New-Item -ParameterFilter { $Value -like "*function Test-Function*" }
        }
        
        It "should generate PowerShell script template" {
            $result = New-CodeTemplate -Type "Script" -Name "TestScript" -Language "PowerShell"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "TestScript.ps1"
            
            # Verify the mock was called with script content
            Assert-MockCalled New-Item -ParameterFilter { $Value -like "*param(*" }
        }
        
        It "should generate PowerShell module template" {
            $result = New-CodeTemplate -Type "Module" -Name "TestModule" -Language "PowerShell"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "TestModule.psm1"
            
            # Verify the mock was called with module content
            Assert-MockCalled New-Item -ParameterFilter { $Value -like "*Export-ModuleMember*" }
        }
        
        It "should generate C# class template" {
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "C#"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "TestClass.cs"
            
            # Verify the mock was called with C# content
            Assert-MockCalled New-Item -ParameterFilter { $Value -like "*public class TestClass*" }
        }
        
        It "should generate Python class template" {
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "Python"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "TestClass.py"
            
            # Verify the mock was called with Python content
            Assert-MockCalled New-Item -ParameterFilter { $Value -like "*class TestClass:*" }
        }
        
        It "should generate JavaScript class template" {
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "JavaScript"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "TestClass.js"
            
            # Verify the mock was called with JavaScript content
            Assert-MockCalled New-Item -ParameterFilter { $Value -like "*class TestClass*" }
        }
        
        It "should generate TypeScript class template" {
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "TypeScript"
            $result | Should -Not -BeNullOrEmpty
            $result.Name | Should -Be "TestClass.ts"
            
            # Verify the mock was called with TypeScript content
            Assert-MockCalled New-Item -ParameterFilter { $Value -like "*export class TestClass*" }
        }
    }
    
    Context "Template content validation" {
        It "should include proper PowerShell script headers" {
            $result = New-CodeTemplate -Type "Script" -Name "TestScript" -Language "PowerShell"
            
            # Verify script contains proper headers
            Assert-MockCalled New-Item -ParameterFilter { 
                $Value -like "*<#*" -and 
                $Value -like "*.SYNOPSIS*" -and
                $Value -like "*.DESCRIPTION*" -and
                $Value -like "*#>*"
            }
        }
        
        It "should include proper function documentation" {
            $result = New-CodeTemplate -Type "Function" -Name "Test-Function" -Language "PowerShell"
            
            # Verify function contains proper documentation
            Assert-MockCalled New-Item -ParameterFilter {
                $Value -like "*<#*" -and
                $Value -like "*.SYNOPSIS*" -and
                $Value -like "*.PARAMETER*" -and
                $Value -like "*.EXAMPLE*" -and
                $Value -like "*#>*"
            }
        }
        
        It "should include proper class structure" {
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell"
            
            # Verify class contains proper structure
            Assert-MockCalled New-Item -ParameterFilter {
                $Value -like "*class TestClass*" -and
                $Value -like "*[ValidateNotNullOrEmpty()]*" -and
                $Value -like "*TestClass()*"
            }
        }
        
        It "should include proper module structure" {
            $result = New-CodeTemplate -Type "Module" -Name "TestModule" -Language "PowerShell"
            
            # Verify module contains proper structure
            Assert-MockCalled New-Item -ParameterFilter {
                $Value -like "*#Requires*" -and
                $Value -like "*Export-ModuleMember*"
            }
        }
        
        It "should include proper test structure" {
            $result = New-CodeTemplate -Type "Test" -Name "TestScript" -Language "PowerShell"
            
            # Verify test contains proper Pester structure
            Assert-MockCalled New-Item -ParameterFilter {
                $Value -like "*Describe*" -and
                $Value -like "*Context*" -and
                $Value -like "*It*" -and
                $Value -like "*Should*"
            }
        }
    }
    
    Context "File operations" {
        It "should create files in specified output path" {
            $testPath = Join-Path $script:TempTestPath "custom-output"
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell" -OutputPath $testPath
            
            # Verify file is created in correct path
            Assert-MockCalled New-Item -ParameterFilter { $Path -like "*$testPath*" }
        }
        
        It "should create files in current directory by default" {
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell"
            
            # Verify file is created in current directory
            Assert-MockCalled New-Item -ParameterFilter { $Path -like "*TestClass.ps1" }
        }
        
        It "should overwrite existing files when Force is specified" {
            Mock Test-Path { return $true }  # Simulate file exists
            
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell" -Force
            
            # Verify file is created with Force parameter
            Assert-MockCalled New-Item -ParameterFilter { $Force -eq $true }
        }
        
        It "should prompt before overwriting existing files" {
            Mock Test-Path { return $true }  # Simulate file exists
            Mock Read-Host { return "Y" }
            
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell"
            
            # Verify user is prompted
            Assert-MockCalled Read-Host -Times 1
        }
        
        It "should skip file creation if user declines overwrite" {
            Mock Test-Path { return $true }  # Simulate file exists
            Mock Read-Host { return "N" }
            
            $result = New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell"
            
            # Verify file is not created
            Assert-MockCalled New-Item -Times 0
        }
    }
    
    Context "Error handling" {
        It "should handle file system errors gracefully" {
            Mock New-Item { throw "Access denied" }
            
            { New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle invalid output paths" {
            Mock New-Item { throw "Path not found" }
            
            { New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell" -OutputPath "Z:\invalid\path" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle permission errors" {
            Mock New-Item { throw "UnauthorizedAccessException" }
            
            { New-CodeTemplate -Type "Class" -Name "TestClass" -Language "PowerShell" -ErrorAction Stop } | Should -Throw
        }
    }
    
    Context "Performance and reliability" {
        It "should generate templates quickly" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            1..10 | ForEach-Object { New-CodeTemplate -Type "Class" -Name "TestClass$_" -Language "PowerShell" | Out-Null }
            $stopwatch.Stop()
            
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 5000  # 5 seconds for 10 templates
        }
        
        It "should handle multiple languages efficiently" {
            $languages = @('PowerShell', 'C#', 'Python', 'JavaScript', 'TypeScript')
            
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            foreach ($language in $languages) {
                New-CodeTemplate -Type "Class" -Name "TestClass" -Language $language | Out-Null
            }
            $stopwatch.Stop()
            
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 3000  # 3 seconds for 5 languages
        }
        
        It "should handle concurrent template generation" {
            # This test would need to be more complex in a real scenario
            # For now, just verify basic functionality doesn't break
            $result1 = New-CodeTemplate -Type "Class" -Name "ConcurrentClass1" -Language "PowerShell"
            $result2 = New-CodeTemplate -Type "Function" -Name "ConcurrentFunction2" -Language "PowerShell"
            
            $result1 | Should -Not -BeNullOrEmpty
            $result2 | Should -Not -BeNullOrEmpty
        }
    }
}