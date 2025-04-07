<#
.SYNOPSIS
    A PowerShell script for generating code templates and boilerplate.

.DESCRIPTION
    This script generates various code templates and boilerplate for different programming languages
    and frameworks. It can create new projects, files, or code snippets based on specified templates.

.PARAMETER Language
    The programming language or framework for which to generate code.
    Supported values: HTML, CSS, JavaScript, PowerShell, Python, CSharp, SQL, Markdown, JSON, YAML.

.PARAMETER TemplateType
    The type of template to generate.
    Supported values depend on the language selected.

.PARAMETER OutputPath
    The path where the generated code should be saved. If not specified, the code is output to the console.

.PARAMETER ProjectName
    The name of the project to create (for project templates).

.PARAMETER Author
    The author name to include in file headers or metadata.

.PARAMETER Description
    A description to include in file headers or metadata.

.PARAMETER License
    The license type to include in file headers or metadata.

.EXAMPLE
    .\Generate-Code.ps1 -Language HTML -TemplateType BasicPage -OutputPath "C:\Projects\index.html"
    Generates a basic HTML page and saves it to the specified path.

.EXAMPLE
    .\Generate-Code.ps1 -Language PowerShell -TemplateType Function
    Outputs a PowerShell function template to the console.

.EXAMPLE
    .\Generate-Code.ps1 -Language JavaScript -TemplateType ReactComponent -OutputPath "C:\Projects\MyComponent.jsx" -Author "John Doe"
    Generates a React component template with the specified author and saves it to the specified path.

.NOTES
    Author: Corey Miller
    Date: April 6, 2025
    Requires: PowerShell 5.1 or later
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateSet("HTML", "CSS", "JavaScript", "PowerShell", "Python", "CSharp", "SQL", "Markdown", "JSON", "YAML")]
    [string]$Language,
    
    [Parameter(Mandatory = $true)]
    [string]$TemplateType,
    
    [Parameter()]
    [string]$OutputPath,
    
    [Parameter()]
    [string]$ProjectName,
    
    [Parameter()]
    [string]$Author = "Corey Miller",
    
    [Parameter()]
    [string]$Description = "",
    
    [Parameter()]
    [string]$License = "MIT"
)

# Function to get the current date in a formatted string
function Get-FormattedDate {
    return (Get-Date -Format "yyyy-MM-dd")
}

# Function to generate HTML templates
function Get-HTMLTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$ProjectName = "My HTML Project",
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description
    )
    
    switch ($TemplateType) {
        "BasicPage" {
            $Template = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="$Description">
    <meta name="author" content="$Author">
    <title>$ProjectName</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        header {
            background-color: #f4f4f4;
            padding: 20px;
            margin-bottom: 20px;
        }
        footer {
            background-color: #f4f4f4;
            padding: 20px;
            margin-top: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>$ProjectName</h1>
            <p>$Description</p>
        </header>
        
        <main>
            <h2>Welcome to My Page</h2>
            <p>This is a basic HTML template. Replace this content with your own.</p>
        </main>
        
        <footer>
            <p>&copy; $(Get-Date -Format "yyyy") $Author. All rights reserved.</p>
        </footer>
    </div>
</body>
</html>
"@
            return $Template
        }
        
        "Form" {
            $Template = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="$Description">
    <meta name="author" content="$Author">
    <title>$ProjectName - Form</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"],
        input[type="email"],
        input[type="password"],
        select,
        textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        button {
            background-color: #4CAF50;
            color: white;
            padding: 10px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>$ProjectName</h1>
        <p>$Description</p>
        
        <form id="myForm" action="#" method="POST">
            <div class="form-group">
                <label for="name">Name:</label>
                <input type="text" id="name" name="name" required>
            </div>
            
            <div class="form-group">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" required>
            </div>
            
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required>
            </div>
            
            <div class="form-group">
                <label for="country">Country:</label>
                <select id="country" name="country">
                    <option value="">Select a country</option>
                    <option value="us">United States</option>
                    <option value="ca">Canada</option>
                    <option value="uk">United Kingdom</option>
                    <option value="au">Australia</option>
                </select>
            </div>
            
            <div class="form-group">
                <label for="message">Message:</label>
                <textarea id="message" name="message" rows="5"></textarea>
            </div>
            
            <div class="form-group">
                <button type="submit">Submit</button>
                <button type="reset">Reset</button>
            </div>
        </form>
        
        <script>
            document.getElementById('myForm').addEventListener('submit', function(event) {
                event.preventDefault();
                alert('Form submitted! In a real application, this would be sent to a server.');
                // Add your form submission logic here
            });
        </script>
    </div>
</body>
</html>
"@
            return $Template
        }
        
        "ResponsiveLayout" {
            $Template = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="$Description">
    <meta name="author" content="$Author">
    <title>$ProjectName - Responsive Layout</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
        
        body {
            font-family: Arial, sans-serif;
            line-height: 1.6;
            color: #333;
        }
        
        .container {
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 15px;
        }
        
        header {
            background-color: #f4f4f4;
            padding: 20px 0;
            margin-bottom: 20px;
        }
        
        nav ul {
            display: flex;
            list-style: none;
            justify-content: space-between;
            padding: 10px 0;
        }
        
        nav ul li a {
            text-decoration: none;
            color: #333;
            font-weight: bold;
        }
        
        .row {
            display: flex;
            flex-wrap: wrap;
            margin: 0 -15px;
        }
        
        .col {
            flex: 1;
            padding: 0 15px;
            margin-bottom: 20px;
        }
        
        .card {
            background-color: #f9f9f9;
            border-radius: 5px;
            padding: 20px;
            height: 100%;
        }
        
        footer {
            background-color: #f4f4f4;
            padding: 20px 0;
            margin-top: 20px;
            text-align: center;
        }
        
        /* Responsive styles */
        @media (max-width: 768px) {
            .row {
                flex-direction: column;
            }
            
            nav ul {
                flex-direction: column;
                align-items: center;
            }
            
            nav ul li {
                margin-bottom: 10px;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="container">
            <h1>$ProjectName</h1>
            <p>$Description</p>
            <nav>
                <ul>
                    <li><a href="#">Home</a></li>
                    <li><a href="#">About</a></li>
                    <li><a href="#">Services</a></li>
                    <li><a href="#">Portfolio</a></li>
                    <li><a href="#">Contact</a></li>
                </ul>
            </nav>
        </div>
    </header>
    
    <main class="container">
        <section>
            <h2>Welcome to Our Responsive Layout</h2>
            <p>This template demonstrates a responsive layout using CSS flexbox. It adapts to different screen sizes.</p>
            
            <div class="row">
                <div class="col">
                    <div class="card">
                        <h3>Column 1</h3>
                        <p>This is the content for column 1. Replace this with your own content.</p>
                    </div>
                </div>
                
                <div class="col">
                    <div class="card">
                        <h3>Column 2</h3>
                        <p>This is the content for column 2. Replace this with your own content.</p>
                    </div>
                </div>
                
                <div class="col">
                    <div class="card">
                        <h3>Column 3</h3>
                        <p>This is the content for column 3. Replace this with your own content.</p>
                    </div>
                </div>
            </div>
        </section>
    </main>
    
    <footer>
        <div class="container">
            <p>&copy; $(Get-Date -Format "yyyy") $Author. All rights reserved.</p>
        </div>
    </footer>
</body>
</html>
"@
            return $Template
        }
        
        default {
            throw "Unsupported HTML template type: $TemplateType. Supported types: BasicPage, Form, ResponsiveLayout"
        }
    }
}

# Function to generate CSS templates
function Get-CSSTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description
    )
    
    switch ($TemplateType) {
        "Reset" {
            $Template = @"
/*
 * CSS Reset
 * Author: $Author
 * Date: $(Get-FormattedDate)
 * Description: $Description
 */

/* Box sizing rules */
*,
*::before,
*::after {
  box-sizing: border-box;
}

/* Remove default margin and padding */
html,
body,
h1,
h2,
h3,
h4,
h5,
h6,
p,
ul,
ol,
li,
figure,
figcaption,
blockquote,
dl,
dd {
  margin: 0;
  padding: 0;
}

/* Set core body defaults */
body {
  min-height: 100vh;
  scroll-behavior: smooth;
  text-rendering: optimizeSpeed;
  line-height: 1.5;
  font-family: Arial, sans-serif;
}

/* Remove list styles on ul, ol elements */
ul,
ol {
  list-style: none;
}

/* Make images easier to work with */
img {
  max-width: 100%;
  display: block;
}

/* Inherit fonts for inputs and buttons */
input,
button,
textarea,
select {
  font: inherit;
}

/* Remove all animations and transitions for people that prefer not to see them */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
"@
            return $Template
        }
        
        "FlexboxLayout" {
            $Template = @"
/*
 * Flexbox Layout
 * Author: $Author
 * Date: $(Get-FormattedDate)
 * Description: $Description
 */

/* Base styles */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: Arial, sans-serif;
  line-height: 1.6;
  color: #333;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 15px;
}

/* Flexbox container */
.flex-container {
  display: flex;
  flex-wrap: wrap;
  margin: 0 -15px;
}

/* Flex items */
.flex-item {
  flex: 1;
  padding: 15px;
  min-width: 200px;
}

/* Responsive flex items */
@media (max-width: 768px) {
  .flex-item {
    flex: 0 0 100%;
  }
}

/* Utility classes */
.flex-center {
  display: flex;
  justify-content: center;
  align-items: center;
}

.flex-between {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.flex-around {
  display: flex;
  justify-content: space-around;
  align-items: center;
}

.flex-column {
  display: flex;
  flex-direction: column;
}

/* Example usage:
<div class="container">
  <div class="flex-container">
    <div class="flex-item">Item 1</div>
    <div class="flex-item">Item 2</div>
    <div class="flex-item">Item 3</div>
  </div>
</div>
*/
"@
            return $Template
        }
        
        "GridLayout" {
            $Template = @"
/*
 * Grid Layout
 * Author: $Author
 * Date: $(Get-FormattedDate)
 * Description: $Description
 */

/* Base styles */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: Arial, sans-serif;
  line-height: 1.6;
  color: #333;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 15px;
}

/* Grid container */
.grid-container {
  display: grid;
  grid-template-columns: repeat(12, 1fr);
  grid-gap: 20px;
}

/* Grid items */
.grid-item {
  padding: 20px;
  background-color: #f4f4f4;
  border-radius: 5px;
}

/* Grid spans */
.span-1 { grid-column: span 1; }
.span-2 { grid-column: span 2; }
.span-3 { grid-column: span 3; }
.span-4 { grid-column: span 4; }
.span-5 { grid-column: span 5; }
.span-6 { grid-column: span 6; }
.span-7 { grid-column: span 7; }
.span-8 { grid-column: span 8; }
.span-9 { grid-column: span 9; }
.span-10 { grid-column: span 10; }
.span-11 { grid-column: span 11; }
.span-12 { grid-column: span 12; }

/* Responsive grid */
@media (max-width: 992px) {
  .grid-container {
    grid-template-columns: repeat(6, 1fr);
  }
}

@media (max-width: 768px) {
  .grid-container {
    grid-template-columns: repeat(4, 1fr);
  }
}

@media (max-width: 576px) {
  .grid-container {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .span-1, .span-2, .span-3, .span-4, .span-5, .span-6,
  .span-7, .span-8, .span-9, .span-10, .span-11, .span-12 {
    grid-column: span 2;
  }
}

/* Example usage:
<div class="container">
  <div class="grid-container">
    <div class="grid-item span-4">Span 4</div>
    <div class="grid-item span-4">Span 4</div>
    <div class="grid-item span-4">Span 4</div>
    <div class="grid-item span-6">Span 6</div>
    <div class="grid-item span-6">Span 6</div>
  </div>
</div>
*/
"@
            return $Template
        }
        
        default {
            throw "Unsupported CSS template type: $TemplateType. Supported types: Reset, FlexboxLayout, GridLayout"
        }
    }
}

# Function to generate JavaScript templates
function Get-JavaScriptTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$ProjectName = "MyProject",
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description
    )
    
    switch ($TemplateType) {
        "Module" {
            $Template = @"
/**
 * @file $ProjectName.js
 * @description $Description
 * @author $Author
 * @date $(Get-FormattedDate)
 */

/**
 * $ProjectName module
 * @module $ProjectName
 */
const $ProjectName = (function() {
    'use strict';
    
    // Private variables
    let _privateVar = 'private';
    
    // Private methods
    function _privateMethod() {
        console.log('This is a private method');
        return _privateVar;
    }
    
    // Public API
    return {
        /**
         * Initialize the module
         * @param {Object} options - Configuration options
         * @returns {void}
         */
        init: function(options = {}) {
            console.log('Initializing $ProjectName module with options:', options);
            // Initialization code here
        },
        
        /**
         * Example public method
         * @param {string} input - Input string
         * @returns {string} Processed string
         */
        doSomething: function(input) {
            console.log('Doing something with:', input);
            _privateMethod();
            return `Processed: ${input}`;
        }
    };
})();

// Export for CommonJS / Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = $ProjectName;
}

// Example usage:
// $ProjectName.init({ debug: true });
// const result = $ProjectName.doSomething('test');
"@
            return $Template
        }
        
        "Class" {
            $Template = @"
/**
 * @file $ProjectName.js
 * @description $Description
 * @author $Author
 * @date $(Get-FormattedDate)
 */

/**
 * $ProjectName class
 */
class $ProjectName {
    /**
     * Create a new $ProjectName instance
     * @param {Object} options - Configuration options
     */
    constructor(options = {}) {
        this.options = options;
        this._privateProperty = 'private';
        console.log('$ProjectName instance created with options:', options);
    }
    
    /**
     * Initialize the instance
     * @returns {void}
     */
    init() {
        console.log('Initializing $ProjectName instance');
        // Initialization code here
    }
    
    /**
     * Example public method
     * @param {string} input - Input string
     * @returns {string} Processed string
     */
    doSomething(input) {
        console.log('Doing something with:', input);
        this._privateMethod();
        return `Processed: ${input}`;
    }
    
    /**
     * Private method (by convention)
     * @private
     * @returns {string} Private property value
     */
    _privateMethod() {
        console.log('This is a private method');
        return this._privateProperty;
    }
    
    /**
     * Static method example
     * @static
     * @param {string} input - Input string
     * @returns {string} Processed string
     */
    static staticMethod(input) {
        console.log('Static method called with:', input);
        return `Static processed: ${input}`;
    }
}

// Export for CommonJS / Node.js
if (typeof module !== 'undefined' && module.exports) {
    module.exports = $ProjectName;
}

// Example usage:
// const instance = new $ProjectName({ debug: true });
// instance.init();
// const result = instance.doSomething('test');
// const staticResult = $ProjectName.staticMethod('test');
"@
            return $Template
        }
        
        "ReactComponent" {
            $Template = @"
/**
 * @file $ProjectName.jsx
 * @description $Description
 * @author $Author
 * @date $(Get-FormattedDate)
 */

import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';

/**
 * $ProjectName component
 * @param {Object} props - Component props
 * @returns {JSX.Element} React component
 */
const $ProjectName = ({ title, children, className, ...restProps }) => {
    // State
    const [count, setCount] = useState(0);
    const [loading, setLoading] = useState(false);
    
    // Effects
    useEffect(() => {
        console.log('$ProjectName component mounted');
        
        // Cleanup function
        return () => {
            console.log('$ProjectName component unmounted');
        };
    }, []);
    
    useEffect(() => {
        console.log('Count changed:', count);
    }, [count]);
    
    // Event handlers
    const handleIncrement = () => {
        setCount(prevCount => prevCount + 1);
    };
    
    const handleDecrement = () => {
        setCount(prevCount => prevCount - 1);
    };
    
    const handleReset = () => {
        setCount(0);
    };
    
    // Render
    return (
        <div className={`$ProjectName ${className || ''}`} {...restProps}>
            <h2>{title}</h2>
            
            <div className="counter">
                <button onClick={handleDecrement}>-</button>
                <span>{count}</span>
                <button onClick={handleIncrement}>+</button>
                <button onClick={handleReset}>Reset</button>
            </div>
            
            <div className="content">
                {children}
            </div>
        </div>
    );
};

// PropTypes
$ProjectName.propTypes = {
    title: PropTypes.string.isRequired,
    children: PropTypes.node,
    className: PropTypes.string,
};

// Default props
$ProjectName.defaultProps = {
    title: '$ProjectName Component',
    children: null,
    className: '',
};

export default $ProjectName;

// Example usage:
// import $ProjectName from './$ProjectName';
// 
// function App() {
//   return (
//     <$ProjectName title="My Component">
//       <p>This is the content of the component.</p>
//     </$ProjectName>
//   );
// }
"@
            return $Template
        }
        
        default {
            throw "Unsupported JavaScript template type: $TemplateType. Supported types: Module, Class, ReactComponent"
        }
    }
}

# Function to generate PowerShell templates
function Get-PowerShellTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$ProjectName = "MyScript",
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description
    )
    
    switch ($TemplateType) {
        "Script" {
            $Template = @"
<#
.SYNOPSIS
    $ProjectName - $Description

.DESCRIPTION
    This script provides functionality to [describe what the script does].
    [Add more detailed description here]

.PARAMETER Param1
    Description of Param1

.PARAMETER Param2
    Description of Param2

.EXAMPLE
    .\$ProjectName.ps1 -Param1 "Value1" -Param2 "Value2"
    Example description of what this does

.NOTES
    Author: $Author
    Date: $(Get-FormattedDate)
    Requires: PowerShell 5.1 or later
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = `$true, HelpMessage = "Enter the value for Param1")]
    [string]`$Param1,
    
    [Parameter(Mandatory = `$false)]
    [string]`$Param2 = "DefaultValue",
    
    [Parameter()]
    [switch]`$Verbose
)

# Script variables
`$ScriptVersion = "1.0.0"
`$ScriptPath = `$PSScriptRoot
`$LogFile = Join-Path -Path `$ScriptPath -ChildPath "$ProjectName.log"

# Function to write to log file
function Write-Log {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = `$true)]
        [string]`$Message,
        
        [Parameter()]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]`$Level = "INFO"
    )
    
    `$Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    `$LogEntry = "`$Timestamp [`$Level] `$Message"
    
    # Write to console
    switch (`$Level) {
        "INFO" { Write-Verbose `$LogEntry }
        "WARNING" { Write-Warning `$Message }
        "ERROR" { Write-Error `$Message }
    }
    
    # Write to log file
    Add-Content -Path `$LogFile -Value `$LogEntry
}

# Function to perform main task
function Invoke-MainTask {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = `$true)]
        [string]`$Param1,
        
        [Parameter()]
        [string]`$Param2
    )
    
    try {
        Write-Log -Message "Starting main task with Param1: `$Param1, Param2: `$Param2" -Level "INFO"
        
        # Your main code logic here
        # ...
        
        Write-Log -Message "Main task completed successfully" -Level "INFO"
        return `$true
    }
    catch {
        Write-Log -Message "Error in main task: `$(`$_.Exception.Message)" -Level "ERROR"
        return `$false
    }
}

# Main script execution
try {
    Write-Log -Message "Script $ProjectName v`$ScriptVersion started" -Level "INFO"
    
    # Validate parameters
    if (`$Param1 -eq "") {
        throw "Param1 cannot be empty"
    }
    
    # Execute main task
    `$Result = Invoke-MainTask -Param1 `$Param1 -Param2 `$Param2
    
    if (`$Result) {
        Write-Output "Script completed successfully"
    }
    else {
        Write-Output "Script completed with errors. Check the log file: `$LogFile"
    }
}
catch {
    Write-Log -Message "Unhandled exception: `$(`$_.Exception.Message)" -Level "ERROR"
    Write-Error "Script failed: `$(`$_.Exception.Message)"
    exit 1
}
finally {
    Write-Log -Message "Script execution completed" -Level "INFO"
}
"@
            return $Template
        }
        
        "Function" {
            $Template = @"
<#
.SYNOPSIS
    $ProjectName - $Description

.DESCRIPTION
    This function provides functionality to [describe what the function does].
    [Add more detailed description here]

.PARAMETER Param1
    Description of Param1

.PARAMETER Param2
    Description of Param2

.EXAMPLE
    $ProjectName -Param1 "Value1" -Param2 "Value2"
    Example description of what this does

.NOTES
    Author: $Author
    Date: $(Get-FormattedDate)
    Requires: PowerShell 5.1 or later
#>
function $ProjectName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = `$true, HelpMessage = "Enter the value for Param1")]
        [string]`$Param1,
        
        [Parameter(Mandatory = `$false)]
        [string]`$Param2 = "DefaultValue"
    )
    
    begin {
        Write-Verbose "Starting `$($MyInvocation.MyCommand.Name)"
        # Initialization code
    }
    
    process {
        try {
            # Main function logic here
            Write-Verbose "Processing with Param1: `$Param1, Param2: `$Param2"
            
            # Example operation
            `$result = "Processed: `$Param1 with `$Param2"
            
            return `$result
        }
        catch {
            Write-Error "An error occurred: `$(`$_.Exception.Message)"
            throw `$_
        }
    }
    
    end {
        Write-Verbose "Completed `$($MyInvocation.MyCommand.Name)"
        # Cleanup code
    }
}
"@
            return $Template
        }
        
        "Module" {
            $Template = @"
<#
.SYNOPSIS
    $ProjectName - PowerShell Module

.DESCRIPTION
    $Description

.NOTES
    Author: $Author
    Date: $(Get-FormattedDate)
    Requires: PowerShell 5.1 or later
#>

# Module manifest
# Run New-ModuleManifest to create this file
# New-ModuleManifest -Path "$ProjectName.psd1" -RootModule "$ProjectName.psm1" -Author "$Author" -Description "$Description"

# Module implementation
function Get-$ProjectName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = `$true)]
        [string]`$InputParam
    )
    
    begin {
        Write-Verbose "Starting Get-$ProjectName"
    }
    
    process {
        try {
            # Function implementation
            return "Processed: `$InputParam"
        }
        catch {
            Write-Error "An error occurred: `$(`$_.Exception.Message)"
            throw `$_
        }
    }
    
    end {
        Write-Verbose "Completed Get-$ProjectName"
    }
}

function Set-$ProjectName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = `$true)]
        [string]`$Name,
        
        [Parameter(Mandatory = `$true)]
        [string]`$Value
    )
    
    begin {
        Write-Verbose "Starting Set-$ProjectName"
    }
    
    process {
        try {
            # Function implementation
            return "Set `$Name to `$Value"
        }
        catch {
            Write-Error "An error occurred: `$(`$_.Exception.Message)"
            throw `$_
        }
    }
    
    end {
        Write-Verbose "Completed Set-$ProjectName"
    }
}

# Export module members
Export-ModuleMember -Function Get-$ProjectName, Set-$ProjectName
"@
            return $Template
        }
        
        default {
            throw "Unsupported PowerShell template type: $TemplateType. Supported types: Script, Function, Module"
        }
    }
}

# Function to generate Python templates
function Get-PythonTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$ProjectName = "my_project",
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description
    )
    
    switch ($TemplateType) {
        "Script" {
            $Template = @'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
{0} - {1}

Author: {2}
Date: {3}
"""

import sys
import os
import argparse
import logging

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger('{0}')

def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description='{1}')
    parser.add_argument('--input', '-i', required=True, help='Input file or directory')
    parser.add_argument('--output', '-o', help='Output file or directory')
    parser.add_argument('--verbose', '-v', action='store_true', help='Enable verbose output')
    
    return parser.parse_args()

def main():
    """Main function."""
    args = parse_arguments()
    
    if args.verbose:
        logger.setLevel(logging.DEBUG)
    
    logger.info(f"Starting {{os.path.basename(__file__)}}")
    logger.debug(f"Arguments: {{args}}")
    
    try:
        # Your code here
        logger.info(f"Processing input: {{args.input}}")
        
        # Example processing
        result = f"Processed {{args.input}}"
        
        # Output handling
        if args.output:
            with open(args.output, 'w') as f:
                f.write(result)
            logger.info(f"Results written to {{args.output}}")
        else:
            print(result)
        
        logger.info("Processing completed successfully")
        return 0
    except Exception as e:
        logger.error(f"An error occurred: {{str(e)}}")
        return 1

if __name__ == "__main__":
    sys.exit(main())
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        "Class" {
            $Template = @'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
{0} - {1}

Author: {2}
Date: {3}
"""

class {0}:
    """
    {1}
    
    Attributes:
        name (str): The name of the instance
        config (dict): Configuration dictionary
    """
    
    def __init__(self, name, config=None):
        """
        Initialize a new {0} instance.
        
        Args:
            name (str): The name of the instance
            config (dict, optional): Configuration dictionary. Defaults to None.
        """
        self.name = name
        self.config = config or {{}}
        self._private_var = None
        
    def initialize(self):
        """Initialize the instance with the provided configuration."""
        print(f"Initializing {{self.name}} with config: {{self.config}}")
        self._private_var = "initialized"
        return True
        
    def process(self, data):
        """
        Process the provided data.
        
        Args:
            data: The data to process
            
        Returns:
            The processed data
        """
        if not self._private_var:
            raise RuntimeError("Instance not initialized. Call initialize() first.")
            
        print(f"Processing data with {{self.name}}")
        return f"Processed: {{data}}"
        
    def _private_method(self):
        """Private method (by convention)."""
        return self._private_var
        
    @staticmethod
    def static_method(input_data):
        """
        Static method example.
        
        Args:
            input_data: The input data
            
        Returns:
            The processed input data
        """
        return f"Static processed: {{input_data}}"
        
    @classmethod
    def from_dict(cls, data_dict):
        """
        Create a new instance from a dictionary.
        
        Args:
            data_dict (dict): Dictionary containing 'name' and optional 'config'
            
        Returns:
            A new {0} instance
        """
        name = data_dict.get('name')
        config = data_dict.get('config')
        return cls(name, config)


# Example usage
if __name__ == "__main__":
    # Create an instance
    instance = {0}("example", {{"debug": True}})
    
    # Initialize
    instance.initialize()
    
    # Process data
    result = instance.process("test data")
    print(result)
    
    # Use static method
    static_result = {0}.static_method("static data")
    print(static_result)
    
    # Create from dictionary
    new_instance = {0}.from_dict({{
        "name": "dict_example",
        "config": {{"debug": False}}
    }})
    new_instance.initialize()
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        default {
            throw "Unsupported Python template type: $TemplateType. Supported types: Script, Class"
        }
    }
}

# Function to generate CSharp templates
function Get-CSharpTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$ProjectName = "MyProject",
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description
    )
    
    switch ($TemplateType) {
        "Class" {
            $Template = @'
/*
 * {0}.cs
 * {1}
 *
 * Author: {2}
 * Date: {3}
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace {0}
{{
    /// <summary>
    /// {1}
    /// </summary>
    public class {0}
    {{
        // Private fields
        private string _name;
        private Dictionary<string, object> _config;
        
        /// <summary>
        /// Gets or sets the name of the instance.
        /// </summary>
        public string Name
        {{
            get {{ return _name; }}
            set {{ _name = value; }}
        }}
        
        /// <summary>
        /// Gets the configuration dictionary.
        /// </summary>
        public IReadOnlyDictionary<string, object> Config => _config;
        
        /// <summary>
        /// Initializes a new instance of the <see cref="{0}"/> class.
        /// </summary>
        public {0}()
        {{
            _name = "Default";
            _config = new Dictionary<string, object>();
        }}
        
        /// <summary>
        /// Initializes a new instance of the <see cref="{0}"/> class with the specified name.
        /// </summary>
        /// <param name="name">The name of the instance.</param>
        public {0}(string name)
        {{
            _name = name;
            _config = new Dictionary<string, object>();
        }}
        
        /// <summary>
        /// Initializes a new instance of the <see cref="{0}"/> class with the specified name and configuration.
        /// </summary>
        /// <param name="name">The name of the instance.</param>
        /// <param name="config">The configuration dictionary.</param>
        public {0}(string name, Dictionary<string, object> config)
        {{
            _name = name;
            _config = config ?? new Dictionary<string, object>();
        }}
        
        /// <summary>
        /// Initializes the instance with the provided configuration.
        /// </summary>
        /// <returns>True if initialization was successful; otherwise, false.</returns>
        public bool Initialize()
        {{
            Console.WriteLine($"Initializing {{_name}} with config: {{string.Join(", ", _config.Select(kv => $"{{kv.Key}}={{kv.Value}}"))}});
            return true;
        }}
        
        /// <summary>
        /// Processes the provided data.
        /// </summary>
        /// <param name="data">The data to process.</param>
        /// <returns>The processed data.</returns>
        public string Process(string data)
        {{
            Console.WriteLine($"Processing data with {{_name}}");
            return $"Processed: {{data}}";
        }}
        
        /// <summary>
        /// Static method example.
        /// </summary>
        /// <param name="input">The input data.</param>
        /// <returns>The processed input data.</returns>
        public static string StaticMethod(string input)
        {{
            return $"Static processed: {{input}}";
        }}
        
        // Private helper method
        private void LogMessage(string message)
        {{
            Console.WriteLine($"[{{DateTime.Now}}] {{message}}");
        }}
    }}
}}

/*
 * Example usage:
 *
 * var instance = new {0}("example");
 * instance.Initialize();
 * var result = instance.Process("test data");
 * Console.WriteLine(result);
 *
 * var staticResult = {0}.StaticMethod("static data");
 * Console.WriteLine(staticResult);
 */
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        "Console" {
            $Template = @'
/*
 * Program.cs
 * {1}
 *
 * Author: {2}
 * Date: {3}
 */

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace {0}
{{
    class Program
    {{
        static void Main(string[] args)
        {{
            Console.WriteLine("{0} - {1}");
            Console.WriteLine("Author: {2}");
            Console.WriteLine("Date: {3}");
            Console.WriteLine();
            
            try
            {{
                // Parse command line arguments
                var arguments = ParseArguments(args);
                
                if (arguments.ContainsKey("help") || args.Length == 0)
                {{
                    ShowHelp();
                    return;
                }}
                
                // Process based on arguments
                if (arguments.ContainsKey("input"))
                {{
                    string inputFile = arguments["input"];
                    Console.WriteLine($"Processing input file: {{inputFile}}");
                    
                    if (!File.Exists(inputFile))
                    {{
                        Console.WriteLine($"Error: Input file '{{inputFile}}' does not exist.");
                        return;
                    }}
                    
                    // Process the file
                    ProcessFile(inputFile, arguments.ContainsKey("output") ? arguments["output"] : null);
                }}
                else
                {{
                    Console.WriteLine("No input file specified. Use --input or -i to specify an input file.");
                    ShowHelp();
                }}
            }}
            catch (Exception ex)
            {{
                Console.WriteLine($"Error: {{ex.Message}}");
                Console.WriteLine(ex.StackTrace);
            }}
            
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }}
        
        static Dictionary<string, string> ParseArguments(string[] args)
        {{
            var result = new Dictionary<string, string>();
            
            for (int i = 0; i < args.Length; i++)
            {{
                string arg = args[i];
                
                if (arg.StartsWith("--"))
                {{
                    string key = arg.Substring(2).ToLower();
                    
                    if (i + 1 < args.Length && !args[i + 1].StartsWith("--"))
                    {{
                        result[key] = args[i + 1];
                        i++;
                    }}
                    else
                    {{
                        result[key] = "true";
                    }}
                }}
                else if (arg.StartsWith("-"))
                {{
                    string key = arg.Substring(1).ToLower();
                    
                    switch (key)
                    {{
                        case "i":
                            key = "input";
                            break;
                        case "o":
                            key = "output";
                            break;
                        case "h":
                            key = "help";
                            break;
                        case "v":
                            key = "verbose";
                            break;
                    }}
                    
                    if (i + 1 < args.Length && !args[i + 1].StartsWith("-"))
                    {{
                        result[key] = args[i + 1];
                        i++;
                    }}
                    else
                    {{
                        result[key] = "true";
                    }}
                }}
            }}
            
            return result;
        }}
        
        static void ShowHelp()
        {{
            Console.WriteLine("Usage: {0} [options]");
            Console.WriteLine();
            Console.WriteLine("Options:");
            Console.WriteLine("  --input, -i <file>    Input file to process");
            Console.WriteLine("  --output, -o <file>   Output file (if not specified, output to console)");
            Console.WriteLine("  --verbose, -v         Enable verbose output");
            Console.WriteLine("  --help, -h            Show this help message");
        }}
        
        static void ProcessFile(string inputFile, string outputFile)
        {{
            // Read the input file
            string content = File.ReadAllText(inputFile);
            
            // Process the content (example)
            string processed = $"Processed: {{content}}";
            
            // Output the result
            if (!string.IsNullOrEmpty(outputFile))
            {{
                File.WriteAllText(outputFile, processed);
                Console.WriteLine($"Output written to: {{outputFile}}");
            }}
            else
            {{
                Console.WriteLine("Processed content:");
                Console.WriteLine(processed);
            }}
        }}
    }}
}}
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        default {
            throw "Unsupported CSharp template type: $TemplateType. Supported types: Class, Console"
        }
    }
}

# Function to generate SQL templates
function Get-SQLTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$ProjectName = "MyTable",
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description
    )
    
    switch ($TemplateType) {
        "Table" {
            $Template = @'
/*
 * Table: {0}
 * {1}
 *
 * Author: {2}
 * Date: {3}
 */

-- Create table
CREATE TABLE {0} (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(MAX),
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    IsActive BIT NOT NULL DEFAULT 1
);

-- Add indexes
CREATE INDEX IX_{0}_Name ON {0} (Name);
CREATE INDEX IX_{0}_CreatedDate ON {0} (CreatedDate);

-- Add comments
EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'{1}',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = '{0}';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Primary key',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = '{0}',
    @level2type = N'COLUMN', @level2name = 'Id';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Name of the record',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = '{0}',
    @level2type = N'COLUMN', @level2name = 'Name';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Description of the record',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = '{0}',
    @level2type = N'COLUMN', @level2name = 'Description';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date when the record was created',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = '{0}',
    @level2type = N'COLUMN', @level2name = 'CreatedDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Date when the record was last modified',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = '{0}',
    @level2type = N'COLUMN', @level2name = 'ModifiedDate';

EXEC sp_addextendedproperty
    @name = N'MS_Description',
    @value = N'Flag indicating if the record is active',
    @level0type = N'SCHEMA', @level0name = 'dbo',
    @level1type = N'TABLE',  @level1name = '{0}',
    @level2type = N'COLUMN', @level2name = 'IsActive';
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        "StoredProcedure" {
            $Template = @'
/*
 * Stored Procedure: {0}
 * {1}
 *
 * Author: {2}
 * Date: {3}
 */

CREATE PROCEDURE [dbo].[{0}]
    @Param1 NVARCHAR(100),
    @Param2 INT = NULL,
    @Param3 BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Declare variables
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        -- Validate parameters
        IF @Param1 IS NULL OR LEN(TRIM(@Param1)) = 0
        BEGIN
            THROW 50000, 'Param1 cannot be null or empty.', 1;
        END
        
        -- Begin transaction
        BEGIN TRANSACTION;
        
        -- Your code here
        -- Example: Insert a record
        INSERT INTO ExampleTable (
            Name,
            Value,
            IsActive,
            CreatedDate
        )
        VALUES (
            @Param1,
            @Param2,
            @Param3,
            GETUTCDATE()
        );
        
        -- Example: Select data
        SELECT
            Id,
            Name,
            Value,
            IsActive,
            CreatedDate
        FROM
            ExampleTable
        WHERE
            Name = @Param1;
        
        -- Commit transaction
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Rollback transaction if it exists
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Get error information
        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        
        -- Rethrow the error
        THROW;
    END CATCH
END
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        default {
            throw "Unsupported SQL template type: $TemplateType. Supported types: Table, StoredProcedure"
        }
    }
}

# Function to generate Markdown templates
function Get-MarkdownTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$ProjectName = "My Project",
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description,
        
        [Parameter()]
        [string]$License
    )
    
    switch ($TemplateType) {
        "README" {
            $Template = @'
# {0}

{1}

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Features](#features)
- [Contributing](#contributing)
- [License](#license)

## Installation

```bash
# Example installation steps
git clone https://github.com/username/{0}.git
cd {0}
npm install  # or pip install, etc.
```

## Usage

```bash
# Example usage
npm start  # or python main.py, etc.
```

## Features

- Feature 1: Description of feature 1
- Feature 2: Description of feature 2
- Feature 3: Description of feature 3

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the {4} License - see the LICENSE file for details.

## Author

- {2}
- Created on: {3}
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate), $License
            return $Template
        }
        
        "Documentation" {
            $Template = @'
# {0} Documentation

{1}

## Overview

This document provides comprehensive documentation for the {0} project.

## Getting Started

### Prerequisites

- Requirement 1
- Requirement 2
- Requirement 3

### Installation

```bash
# Installation steps
```

## Architecture

### Component 1

Description of component 1.

### Component 2

Description of component 2.

## API Reference

### Function/Method 1

```
function1(param1, param2)
```

**Parameters:**
- `param1` (type): Description of param1
- `param2` (type): Description of param2

**Returns:**
- (type): Description of return value

**Example:**
```
// Example usage
```

### Function/Method 2

```
function2(param1, param2)
```

**Parameters:**
- `param1` (type): Description of param1
- `param2` (type): Description of param2

**Returns:**
- (type): Description of return value

**Example:**
```
// Example usage
```

## Configuration

### Configuration File

```
# Example configuration file
```

### Environment Variables

- `ENV_VAR_1`: Description of environment variable 1
- `ENV_VAR_2`: Description of environment variable 2

## Troubleshooting

### Common Issue 1

Description of issue 1 and how to resolve it.

### Common Issue 2

Description of issue 2 and how to resolve it.

## Author

- {2}
- Last Updated: {3}
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        default {
            throw "Unsupported Markdown template type: $TemplateType. Supported types: README, Documentation"
        }
    }
}

# Function to generate JSON templates
function Get-JSONTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$ProjectName = "MyProject",
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description
    )
    
    switch ($TemplateType) {
        "Config" {
            $Template = @'
{
  "name": "{0}",
  "version": "1.0.0",
  "description": "{1}",
  "author": "{2}",
  "created": "{3}",
  "config": {
    "environment": "development",
    "debug": true,
    "logLevel": "info",
    "port": 3000,
    "database": {
      "host": "localhost",
      "port": 5432,
      "name": "mydb",
      "user": "user",
      "password": "password"
    },
    "api": {
      "baseUrl": "https://api.example.com",
      "timeout": 5000,
      "retries": 3
    },
    "features": {
      "feature1": true,
      "feature2": false,
      "feature3": {
        "enabled": true,
        "options": {
          "option1": "value1",
          "option2": "value2"
        }
      }
    }
  }
}
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        "Package" {
            $Template = @'
{
  "name": "{0}",
  "version": "1.0.0",
  "description": "{1}",
  "author": "{2}",
  "license": "MIT",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "test": "jest",
    "lint": "eslint .",
    "build": "webpack --mode production"
  },
  "keywords": [
    "example",
    "template",
    "project"
  ],
  "dependencies": {
    "express": "^4.17.1",
    "lodash": "^4.17.21",
    "axios": "^0.21.1"
  },
  "devDependencies": {
    "jest": "^27.0.6",
    "eslint": "^7.32.0",
    "webpack": "^5.50.0",
    "webpack-cli": "^4.8.0"
  },
  "repository": {
    "type": "git",
    "url": "https://github.com/username/{0}.git"
  },
  "bugs": {
    "url": "https://github.com/username/{0}/issues"
  },
  "homepage": "https://github.com/username/{0}#readme"
}
'@ -f $ProjectName, $Description, $Author
            return $Template
        }
        
        default {
            throw "Unsupported JSON template type: $TemplateType. Supported types: Config, Package"
        }
    }
}

# Function to generate YAML templates
function Get-YAMLTemplate {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TemplateType,
        
        [Parameter()]
        [string]$ProjectName = "MyProject",
        
        [Parameter()]
        [string]$Author,
        
        [Parameter()]
        [string]$Description
    )
    
    switch ($TemplateType) {
        "Config" {
            $Template = @'
# {0} Configuration
# {1}
# Author: {2}
# Date: {3}

# Application settings
app:
  name: {0}
  version: 1.0.0
  description: {1}
  environment: development
  debug: true
  log_level: info
  port: 3000

# Database configuration
database:
  host: localhost
  port: 5432
  name: mydb
  user: user
  password: password
  pool:
    min: 5
    max: 20
    idle_timeout: 10000

# API configuration
api:
  base_url: https://api.example.com
  timeout: 5000
  retries: 3
  endpoints:
    users: /api/users
    products: /api/products
    orders: /api/orders

# Feature flags
features:
  feature1: true
  feature2: false
  feature3:
    enabled: true
    options:
      option1: value1
      option2: value2

# Logging configuration
logging:
  console:
    enabled: true
    level: info
  file:
    enabled: true
    level: debug
    path: ./logs
    filename: app.log
    max_size: 10m
    max_files: 5

# Security settings
security:
  jwt:
    secret: your-secret-key
    expiration: 3600
  cors:
    allowed_origins:
      - http://localhost:3000
      - https://example.com
    allowed_methods:
      - GET
      - POST
      - PUT
      - DELETE
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        "Docker" {
            $Template = @'
# {0} Docker Compose Configuration
# {1}
# Author: {2}
# Date: {3}

version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: {0}-app
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgres://postgres:postgres@db:5432/mydb
    volumes:
      - ./:/app
      - /app/node_modules
    depends_on:
      - db
    networks:
      - app-network

  db:
    image: postgres:13
    container_name: {0}-db
    restart: unless-stopped
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=mydb
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:6
    container_name: {0}-redis
    restart: unless-stopped
    ports:
      - "6379:6379"
    volumes:
      - redis-data:/data
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  postgres-data:
  redis-data:
'@ -f $ProjectName, $Description, $Author, (Get-FormattedDate)
            return $Template
        }
        
        default {
            throw "Unsupported YAML template type: $TemplateType. Supported types: Config, Docker"
        }
    }
}

# Main script execution
try {
    # Validate parameters
    if ([string]::IsNullOrEmpty($ProjectName)) {
        $ProjectName = switch ($Language) {
            "HTML" { "MyHTMLProject" }
            "CSS" { "MyStyles" }
            "JavaScript" { "MyJavaScriptProject" }
            "PowerShell" { "MyPowerShellScript" }
            "Python" { "my_python_project" }
            "CSharp" { "MyCSharpProject" }
            "SQL" { "MyDatabase" }
            "Markdown" { "MyDocument" }
            "JSON" { "MyConfig" }
            "YAML" { "MyConfig" }
            default { "MyProject" }
        }
    }

    # Get the appropriate template based on the language
    $Template = switch ($Language) {
        "HTML" { Get-HTMLTemplate -TemplateType $TemplateType -ProjectName $ProjectName -Author $Author -Description $Description }
        "CSS" { Get-CSSTemplate -TemplateType $TemplateType -Author $Author -Description $Description }
        "JavaScript" { Get-JavaScriptTemplate -TemplateType $TemplateType -ProjectName $ProjectName -Author $Author -Description $Description }
        "PowerShell" { Get-PowerShellTemplate -TemplateType $TemplateType -ProjectName $ProjectName -Author $Author -Description $Description }
        "Python" { Get-PythonTemplate -TemplateType $TemplateType -ProjectName $ProjectName -Author $Author -Description $Description }
        "CSharp" { Get-CSharpTemplate -TemplateType $TemplateType -ProjectName $ProjectName -Author $Author -Description $Description }
        "SQL" { Get-SQLTemplate -TemplateType $TemplateType -ProjectName $ProjectName -Author $Author -Description $Description }
        "Markdown" { Get-MarkdownTemplate -TemplateType $TemplateType -ProjectName $ProjectName -Author $Author -Description $Description -License $License }
        "JSON" { Get-JSONTemplate -TemplateType $TemplateType -ProjectName $ProjectName -Author $Author -Description $Description }
        "YAML" { Get-YAMLTemplate -TemplateType $TemplateType -ProjectName $ProjectName -Author $Author -Description $Description }
        default { throw "Unsupported language: $Language" }
    }

    # Output the template
    if ([string]::IsNullOrEmpty($OutputPath)) {
        # Output to console
        Write-Output $Template
    }
    else {
        # Create directory if it doesn't exist
        $Directory = Split-Path -Path $OutputPath -Parent
        if (-not [string]::IsNullOrEmpty($Directory) -and -not (Test-Path -Path $Directory)) {
            New-Item -Path $Directory -ItemType Directory -Force | Out-Null
        }

        # Write to file
        $Template | Out-File -FilePath $OutputPath -Encoding utf8 -Force
        Write-Output "Template generated and saved to: $OutputPath"
    }
}
catch {
    Write-Error "Error generating template: $_"
    exit 1
}
