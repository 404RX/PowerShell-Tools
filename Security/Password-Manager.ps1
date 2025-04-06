<#
.SYNOPSIS
    A secure password generator and manager.

.DESCRIPTION
    This script provides functionality to generate secure passwords based on various criteria
    and securely store and retrieve passwords using Windows Data Protection API (DPAPI).

.PARAMETER Action
    The action to perform: Generate, Store, Retrieve, List, or Remove.

.PARAMETER ServiceName
    The name of the service or website for which the password is being generated, stored, or retrieved.

.PARAMETER Username
    The username associated with the password.

.PARAMETER Length
    The length of the password to generate. Default is 16.

.PARAMETER IncludeSpecialChars
    Whether to include special characters in the generated password. Default is $true.

.PARAMETER IncludeNumbers
    Whether to include numbers in the generated password. Default is $true.

.PARAMETER IncludeUppercase
    Whether to include uppercase letters in the generated password. Default is $true.

.PARAMETER IncludeLowercase
    Whether to include lowercase letters in the generated password. Default is $true.

.PARAMETER ExcludeSimilarChars
    Whether to exclude similar characters (e.g., 1, l, I, 0, O) in the generated password. Default is $true.

.PARAMETER ExcludeAmbiguousChars
    Whether to exclude ambiguous characters (e.g., {, }, [, ], (, ), /, \, ', ", `, ~, ,, ;, :, ., <, >) in the generated password. Default is $false.

.PARAMETER StorePath
    The path to the password store file. Default is "$env:USERPROFILE\Documents\PasswordStore.xml".

.EXAMPLE
    .\Password-Manager.ps1 -Action Generate -Length 20 -IncludeSpecialChars $true
    Generates a secure password of length 20 with special characters.

.EXAMPLE
    .\Password-Manager.ps1 -Action Store -ServiceName "Gmail" -Username "user@gmail.com"
    Prompts for a password and securely stores it for the specified service and username.

.EXAMPLE
    .\Password-Manager.ps1 -Action Retrieve -ServiceName "Gmail" -Username "user@gmail.com"
    Retrieves the password for the specified service and username.

.EXAMPLE
    .\Password-Manager.ps1 -Action List
    Lists all stored service names and usernames.

.EXAMPLE
    .\Password-Manager.ps1 -Action Remove -ServiceName "Gmail" -Username "user@gmail.com"
    Removes the stored password for the specified service and username.

.NOTES
    Author: Corey Miller
    Date: April 6, 2025
    Requires: PowerShell 5.1 or later
    Requires: Windows platform for DPAPI functionality
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("Generate", "Store", "Retrieve", "List", "Remove")]
    [string]$Action,
    
    [Parameter()]
    [string]$ServiceName,
    
    [Parameter()]
    [string]$Username,
    
    [Parameter()]
    [int]$Length = 16,
    
    [Parameter()]
    [bool]$IncludeSpecialChars = $true,
    
    [Parameter()]
    [bool]$IncludeNumbers = $true,
    
    [Parameter()]
    [bool]$IncludeUppercase = $true,
    
    [Parameter()]
    [bool]$IncludeLowercase = $true,
    
    [Parameter()]
    [bool]$ExcludeSimilarChars = $true,
    
    [Parameter()]
    [bool]$ExcludeAmbiguousChars = $false,
    
    [Parameter()]
    [string]$StorePath = "$env:USERPROFILE\Documents\PasswordStore.xml"
)

# Add the System.Security assembly for DPAPI
Add-Type -AssemblyName System.Security

# Function to generate a secure password
function New-SecurePassword {
    param (
        [Parameter(Mandatory = $true)]
        [int]$Length,
        
        [Parameter()]
        [bool]$IncludeSpecialChars = $true,
        
        [Parameter()]
        [bool]$IncludeNumbers = $true,
        
        [Parameter()]
        [bool]$IncludeUppercase = $true,
        
        [Parameter()]
        [bool]$IncludeLowercase = $true,
        
        [Parameter()]
        [bool]$ExcludeSimilarChars = $true,
        
        [Parameter()]
        [bool]$ExcludeAmbiguousChars = $false
    )
    
    # Define character sets
    $LowercaseChars = "abcdefghijklmnopqrstuvwxyz"
    $UppercaseChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $NumberChars = "0123456789"
    $SpecialChars = "!@#$%^&*()-_=+[]{}|;:,.<>?"
    
    # Remove similar characters if specified
    if ($ExcludeSimilarChars) {
        $LowercaseChars = $LowercaseChars -replace "[il]", ""
        $UppercaseChars = $UppercaseChars -replace "[IO]", ""
        $NumberChars = $NumberChars -replace "[10]", ""
    }
    
    # Remove ambiguous characters if specified
    if ($ExcludeAmbiguousChars) {
        $SpecialChars = $SpecialChars -replace "[\[\]{}()/\\'\`"~,;:.<>]", ""
    }
    
    # Build the character set based on inclusion parameters
    $CharSet = ""
    if ($IncludeLowercase) { $CharSet += $LowercaseChars }
    if ($IncludeUppercase) { $CharSet += $UppercaseChars }
    if ($IncludeNumbers) { $CharSet += $NumberChars }
    if ($IncludeSpecialChars) { $CharSet += $SpecialChars }
    
    # Ensure at least one character set is included
    if ($CharSet.Length -eq 0) {
        Write-Error "At least one character set must be included."
        return $null
    }
    
    # Generate the password
    $Password = ""
    $Random = New-Object System.Random
    
    # Ensure at least one character from each included set
    if ($IncludeLowercase -and $LowercaseChars.Length -gt 0) {
        $Password += $LowercaseChars[$Random.Next(0, $LowercaseChars.Length)]
    }
    
    if ($IncludeUppercase -and $UppercaseChars.Length -gt 0) {
        $Password += $UppercaseChars[$Random.Next(0, $UppercaseChars.Length)]
    }
    
    if ($IncludeNumbers -and $NumberChars.Length -gt 0) {
        $Password += $NumberChars[$Random.Next(0, $NumberChars.Length)]
    }
    
    if ($IncludeSpecialChars -and $SpecialChars.Length -gt 0) {
        $Password += $SpecialChars[$Random.Next(0, $SpecialChars.Length)]
    }
    
    # Fill the rest of the password
    for ($i = $Password.Length; $i -lt $Length; $i++) {
        $Password += $CharSet[$Random.Next(0, $CharSet.Length)]
    }
    
    # Shuffle the password
    $PasswordArray = $Password.ToCharArray()
    $n = $PasswordArray.Length
    while ($n -gt 1) {
        $n--
        $k = $Random.Next(0, $n + 1)
        $temp = $PasswordArray[$k]
        $PasswordArray[$k] = $PasswordArray[$n]
        $PasswordArray[$n] = $temp
    }
    
    return -join $PasswordArray
}

# Function to encrypt a string using DPAPI
function Protect-String {
    param (
        [Parameter(Mandatory = $true)]
        [string]$String
    )
    
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
    $EncryptedBytes = [System.Security.Cryptography.ProtectedData]::Protect(
        $Bytes,
        $null,
        [System.Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    
    return [Convert]::ToBase64String($EncryptedBytes)
}

# Function to decrypt a string using DPAPI
function Unprotect-String {
    param (
        [Parameter(Mandatory = $true)]
        [string]$EncryptedString
    )
    
    try {
        $EncryptedBytes = [Convert]::FromBase64String($EncryptedString)
        $Bytes = [System.Security.Cryptography.ProtectedData]::Unprotect(
            $EncryptedBytes,
            $null,
            [System.Security.Cryptography.DataProtectionScope]::CurrentUser
        )
        
        return [System.Text.Encoding]::UTF8.GetString($Bytes)
    }
    catch {
        Write-Error "Failed to decrypt the string. It may have been encrypted by a different user or on a different machine."
        return $null
    }
}

# Function to initialize or load the password store
function Get-PasswordStore {
    param (
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )
    
    if (Test-Path $StorePath) {
        try {
            $Store = Import-Clixml -Path $StorePath
            return $Store
        }
        catch {
            Write-Error "Failed to load the password store. Creating a new one."
        }
    }
    
    # Create a new store if it doesn't exist or couldn't be loaded
    $Store = @{}
    return $Store
}

# Function to save the password store
function Save-PasswordStore {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Store,
        
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )
    
    try {
        # Create the directory if it doesn't exist
        $Directory = Split-Path -Path $StorePath -Parent
        if (-not (Test-Path $Directory)) {
            New-Item -Path $Directory -ItemType Directory -Force | Out-Null
        }
        
        # Export the store
        $Store | Export-Clixml -Path $StorePath
        return $true
    }
    catch {
        Write-Error "Failed to save the password store: $_"
        return $false
    }
}

# Function to store a password
function Set-Password {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,
        
        [Parameter(Mandatory = $true)]
        [string]$Username,
        
        [Parameter(Mandatory = $true)]
        [string]$Password,
        
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )
    
    # Load the store
    $Store = Get-PasswordStore -StorePath $StorePath
    
    # Create the service entry if it doesn't exist
    if (-not $Store.ContainsKey($ServiceName)) {
        $Store[$ServiceName] = @{}
    }
    
    # Encrypt and store the password
    $EncryptedPassword = Protect-String -String $Password
    $Store[$ServiceName][$Username] = $EncryptedPassword
    
    # Save the store
    $Success = Save-PasswordStore -Store $Store -StorePath $StorePath
    
    if ($Success) {
        Write-Host "Password for $ServiceName / $Username has been securely stored." -ForegroundColor Green
    }
    else {
        Write-Error "Failed to store the password."
    }
}

# Function to retrieve a password
function Get-Password {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,
        
        [Parameter(Mandatory = $true)]
        [string]$Username,
        
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )
    
    # Load the store
    $Store = Get-PasswordStore -StorePath $StorePath
    
    # Check if the service and username exist
    if (-not $Store.ContainsKey($ServiceName) -or -not $Store[$ServiceName].ContainsKey($Username)) {
        Write-Error "No password found for $ServiceName / $Username."
        return $null
    }
    
    # Decrypt and return the password
    $EncryptedPassword = $Store[$ServiceName][$Username]
    $Password = Unprotect-String -EncryptedString $EncryptedPassword
    
    return $Password
}

# Function to list all stored services and usernames
function Get-PasswordList {
    param (
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )
    
    # Load the store
    $Store = Get-PasswordStore -StorePath $StorePath
    
    # Create a list of all services and usernames
    $List = @()
    foreach ($ServiceName in $Store.Keys) {
        foreach ($Username in $Store[$ServiceName].Keys) {
            $List += [PSCustomObject]@{
                ServiceName = $ServiceName
                Username = $Username
            }
        }
    }
    
    return $List
}

# Function to remove a stored password
function Remove-Password {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,
        
        [Parameter(Mandatory = $true)]
        [string]$Username,
        
        [Parameter(Mandatory = $true)]
        [string]$StorePath
    )
    
    # Load the store
    $Store = Get-PasswordStore -StorePath $StorePath
    
    # Check if the service and username exist
    if (-not $Store.ContainsKey($ServiceName) -or -not $Store[$ServiceName].ContainsKey($Username)) {
        Write-Error "No password found for $ServiceName / $Username."
        return $false
    }
    
    # Remove the password
    $Store[$ServiceName].Remove($Username)
    
    # Remove the service if it's empty
    if ($Store[$ServiceName].Count -eq 0) {
        $Store.Remove($ServiceName)
    }
    
    # Save the store
    $Success = Save-PasswordStore -Store $Store -StorePath $StorePath
    
    if ($Success) {
        Write-Host "Password for $ServiceName / $Username has been removed." -ForegroundColor Green
        return $true
    }
    else {
        Write-Error "Failed to remove the password."
        return $false
    }
}

# Main execution
switch ($Action) {
    "Generate" {
        $Password = New-SecurePassword -Length $Length -IncludeSpecialChars $IncludeSpecialChars -IncludeNumbers $IncludeNumbers -IncludeUppercase $IncludeUppercase -IncludeLowercase $IncludeLowercase -ExcludeSimilarChars $ExcludeSimilarChars -ExcludeAmbiguousChars $ExcludeAmbiguousChars
        
        if ($Password) {
            Write-Host "Generated Password: $Password" -ForegroundColor Cyan
            
            # Calculate password strength
            $Strength = 0
            if ($IncludeLowercase) { $Strength += 26 }
            if ($IncludeUppercase) { $Strength += 26 }
            if ($IncludeNumbers) { $Strength += 10 }
            if ($IncludeSpecialChars) { $Strength += 32 }
            
            $Entropy = [Math]::Log([Math]::Pow($Strength, $Length), 2)
            $EntropyRounded = [Math]::Round($Entropy, 2)
            
            # Determine strength rating
            $StrengthRating = "Weak"
            if ($Entropy -ge 80) {
                $StrengthRating = "Very Strong"
                $ColorChoice = "Cyan"
            }
            elseif ($Entropy -ge 60) {
                $StrengthRating = "Strong"
                $ColorChoice = "Green"
            }
            elseif ($Entropy -ge 40) {
                $StrengthRating = "Moderate"
                $ColorChoice = "Yellow"
            }
            else {
                $ColorChoice = "Red"
            }
            
            Write-Host "Password Strength: $StrengthRating (Entropy: $EntropyRounded bits)" -ForegroundColor $ColorChoice
            
            # Ask if the user wants to store the password
            if ($ServiceName -and $Username) {
                $StorePassword = Read-Host "Do you want to store this password for $ServiceName / $Username? (Y/N)"
                if ($StorePassword -eq "Y" -or $StorePassword -eq "y") {
                    Set-Password -ServiceName $ServiceName -Username $Username -Password $Password -StorePath $StorePath
                }
            }
        }
    }
    
    "Store" {
        if (-not $ServiceName -or -not $Username) {
            Write-Error "ServiceName and Username are required for the Store action."
            break
        }
        
        $SecurePassword = Read-Host -AsSecureString "Enter the password to store"
        $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))
        
        Set-Password -ServiceName $ServiceName -Username $Username -Password $Password -StorePath $StorePath
    }
    
    "Retrieve" {
        if (-not $ServiceName -or -not $Username) {
            Write-Error "ServiceName and Username are required for the Retrieve action."
            break
        }
        
        $Password = Get-Password -ServiceName $ServiceName -Username $Username -StorePath $StorePath
        
        if ($Password) {
            Write-Host "Password for $ServiceName / $Username:" -ForegroundColor Green
            Write-Host $Password
        }
    }
    
    "List" {
        $List = Get-PasswordList -StorePath $StorePath
        
        if ($List.Count -eq 0) {
            Write-Host "No passwords stored." -ForegroundColor Yellow
        }
        else {
            Write-Host "Stored Passwords:" -ForegroundColor Green
            $List | Format-Table -AutoSize
        }
    }
    
    "Remove" {
        if (-not $ServiceName -or -not $Username) {
            Write-Error "ServiceName and Username are required for the Remove action."
            break
        }
        
        Remove-Password -ServiceName $ServiceName -Username $Username -StorePath $StorePath
    }
}
