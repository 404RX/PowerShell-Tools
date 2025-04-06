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
    [CmdletBinding
