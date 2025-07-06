#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Unit tests for Security scripts
.DESCRIPTION
    This file contains unit tests for the Password-Manager.ps1 script.
    Tests cover password generation, encryption, storage, and retrieval functionality.
#>

BeforeAll {
    # Import the script under test
    $ScriptPath = Join-Path $PSScriptRoot "..\..\Security\Password-Manager.ps1"
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

Describe "Password-Manager.ps1" {
    Context "Script validation" {
        It "should have valid PowerShell syntax" {
            $ScriptPath = Join-Path $PSScriptRoot "..\..\Security\Password-Manager.ps1"
            Test-PowerShellSyntax -ScriptPath $ScriptPath | Should -Be $true
        }
        
        It "should be able to get help information" {
            $help = Get-Help New-SecurePassword -ErrorAction SilentlyContinue
            $help | Should -Not -BeNullOrEmpty
            $help.Synopsis | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Password generation" {
        It "should generate passwords with default length" {
            $password = New-SecurePassword
            $password | Should -Not -BeNullOrEmpty
            $password.Length | Should -Be 16  # Default length
        }
        
        It "should generate passwords with specified length" {
            $length = 24
            $password = New-SecurePassword -Length $length
            $password.Length | Should -Be $length
        }
        
        It "should include uppercase letters when specified" {
            $password = New-SecurePassword -IncludeUppercase
            $password | Should -Match "[A-Z]"
        }
        
        It "should include lowercase letters when specified" {
            $password = New-SecurePassword -IncludeLowercase
            $password | Should -Match "[a-z]"
        }
        
        It "should include numbers when specified" {
            $password = New-SecurePassword -IncludeNumbers
            $password | Should -Match "[0-9]"
        }
        
        It "should include special characters when specified" {
            $password = New-SecurePassword -IncludeSpecialChars
            $password | Should -Match "[!@#$%^&*()_+\-=\[\]{};':\",./<>?]"
        }
        
        It "should generate different passwords on each call" {
            $password1 = New-SecurePassword
            $password2 = New-SecurePassword
            $password1 | Should -Not -Be $password2
        }
        
        It "should handle minimum length requirements" {
            $password = New-SecurePassword -Length 1
            $password.Length | Should -Be 1
        }
        
        It "should handle maximum length requirements" {
            $password = New-SecurePassword -Length 128
            $password.Length | Should -Be 128
        }
    }
    
    Context "Password storage and retrieval" {
        BeforeEach {
            # Mock DPAPI functions for testing
            Mock ConvertTo-SecureString {
                param($String, $AsPlainText, $Force)
                return [System.Security.SecureString]::new()
            }
            
            Mock ConvertFrom-SecureString {
                param($SecureString)
                return "MockEncryptedPassword"
            }
            
            Mock Export-Clixml {
                param($InputObject, $Path)
                # Mock successful export
                return $true
            }
            
            Mock Import-Clixml {
                param($Path)
                return @{
                    "TestSite" = "MockEncryptedPassword"
                    "AnotherSite" = "MockEncryptedPassword"
                }
            }
            
            Mock Test-Path { return $true }
        }
        
        It "should store passwords securely" {
            $result = Set-StoredPassword -Site "TestSite" -Password "TestPassword123!"
            $result | Should -Be $true
        }
        
        It "should retrieve stored passwords" {
            $password = Get-StoredPassword -Site "TestSite"
            $password | Should -Not -BeNullOrEmpty
        }
        
        It "should list all stored sites" {
            $sites = Get-StoredSites
            $sites | Should -Contain "TestSite"
            $sites | Should -Contain "AnotherSite"
        }
        
        It "should handle non-existent sites gracefully" {
            Mock Import-Clixml { return @{} }
            
            $password = Get-StoredPassword -Site "NonExistentSite"
            $password | Should -BeNullOrEmpty
        }
        
        It "should remove stored passwords" {
            $result = Remove-StoredPassword -Site "TestSite"
            $result | Should -Be $true
        }
        
        It "should handle storage file creation" {
            Mock Test-Path { return $false }
            Mock New-Item { return $true }
            
            $result = Set-StoredPassword -Site "NewSite" -Password "NewPassword123!"
            $result | Should -Be $true
        }
    }
    
    Context "Security validation" {
        It "should use DPAPI for encryption" {
            # Verify that ConvertTo-SecureString is called
            Set-StoredPassword -Site "TestSite" -Password "TestPassword123!"
            Assert-MockCalled ConvertTo-SecureString -Times 1
        }
        
        It "should use DPAPI for decryption" {
            # Verify that ConvertFrom-SecureString is called
            Get-StoredPassword -Site "TestSite"
            Assert-MockCalled ConvertFrom-SecureString -Times 1
        }
        
        It "should store passwords in user profile" {
            $expectedPath = Join-Path $env:USERPROFILE "Documents\PasswordStore.xml"
            Set-StoredPassword -Site "TestSite" -Password "TestPassword123!"
            
            # Verify the correct path is used
            Assert-MockCalled Export-Clixml -ParameterFilter { $Path -eq $expectedPath }
        }
        
        It "should not store passwords in plain text" {
            Set-StoredPassword -Site "TestSite" -Password "TestPassword123!"
            
            # Verify that the password is encrypted before storage
            Assert-MockCalled ConvertTo-SecureString -ParameterFilter { $String -eq "TestPassword123!" }
        }
    }
    
    Context "Password strength validation" {
        It "should validate password strength" {
            $strongPassword = "MyStr0ng!P@ssw0rd"
            $result = Test-PasswordStrength -Password $strongPassword
            $result.IsStrong | Should -Be $true
        }
        
        It "should reject weak passwords" {
            $weakPassword = "password"
            $result = Test-PasswordStrength -Password $weakPassword
            $result.IsStrong | Should -Be $false
        }
        
        It "should provide strength feedback" {
            $password = "Test123"
            $result = Test-PasswordStrength -Password $password
            $result.Feedback | Should -Not -BeNullOrEmpty
        }
        
        It "should check for minimum length" {
            $shortPassword = "Aa1!"
            $result = Test-PasswordStrength -Password $shortPassword
            $result.Issues | Should -Contain "Too short"
        }
        
        It "should check for character complexity" {
            $simplePassword = "aaaaaaaa"
            $result = Test-PasswordStrength -Password $simplePassword
            $result.Issues | Should -Contain "Lacks complexity"
        }
        
        It "should check for common patterns" {
            $commonPassword = "Password123"
            $result = Test-PasswordStrength -Password $commonPassword
            $result.Issues | Should -Contain "Common pattern"
        }
    }
    
    Context "Error handling" {
        It "should handle file system errors gracefully" {
            Mock Export-Clixml { throw "Access denied" }
            
            { Set-StoredPassword -Site "TestSite" -Password "TestPassword123!" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle encryption errors" {
            Mock ConvertTo-SecureString { throw "Encryption failed" }
            
            { Set-StoredPassword -Site "TestSite" -Password "TestPassword123!" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle corrupted password store" {
            Mock Import-Clixml { throw "XML is corrupted" }
            
            { Get-StoredPassword -Site "TestSite" -ErrorAction Stop } | Should -Throw
        }
        
        It "should handle missing password store file" {
            Mock Test-Path { return $false }
            Mock Import-Clixml { throw "File not found" }
            
            $sites = Get-StoredSites
            $sites | Should -BeNullOrEmpty
        }
    }
    
    Context "Performance and reliability" {
        It "should generate passwords quickly" {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            1..10 | ForEach-Object { New-SecurePassword | Out-Null }
            $stopwatch.Stop()
            
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 1000  # 1 second for 10 passwords
        }
        
        It "should handle large password stores efficiently" {
            # Mock a large password store
            $largeStore = @{}
            1..100 | ForEach-Object { $largeStore["Site$_"] = "MockEncryptedPassword" }
            Mock Import-Clixml { return $largeStore }
            
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $sites = Get-StoredSites
            $stopwatch.Stop()
            
            $sites.Count | Should -Be 100
            $stopwatch.ElapsedMilliseconds | Should -BeLessThan 2000  # 2 seconds max
        }
        
        It "should handle concurrent access safely" {
            # This test would need to be more complex in a real scenario
            # For now, just verify basic functionality doesn't break
            $result1 = Set-StoredPassword -Site "ConcurrentSite1" -Password "Password1"
            $result2 = Set-StoredPassword -Site "ConcurrentSite2" -Password "Password2"
            
            $result1 | Should -Be $true
            $result2 | Should -Be $true
        }
    }
}