# Testing Framework for PowerShell-Tools

This document describes the comprehensive testing framework for the PowerShell-Tools repository.

## Overview

The testing framework uses **Pester**, the standard PowerShell testing framework, to ensure all scripts work correctly and maintain high code quality. The framework includes:

- **Unit Tests**: Test individual functions and components in isolation
- **Integration Tests**: Test complete workflows and cross-script functionality
- **Security Analysis**: Automated security scanning and validation
- **Code Coverage**: Measure test coverage across all scripts
- **CI/CD Integration**: Automated testing on every commit and pull request

## Quick Start

### Prerequisites

- PowerShell 5.1 or later (PowerShell 7.x recommended)
- Pester module (automatically installed if missing)

### Running Tests

```powershell
# Run all tests
.\RunTests.ps1

# Run only unit tests
.\RunTests.ps1 -TestType Unit

# Run only integration tests
.\RunTests.ps1 -TestType Integration

# Run with detailed output
.\RunTests.ps1 -ShowDetails

# Run in CI mode with coverage
.\RunTests.ps1 -TestType All -OutputFormat NUnitXml -CI
```

## Test Structure

```
PowerShell-Tools/
├── Tests/
│   ├── Unit/                          # Unit tests for individual scripts
│   │   ├── System-Administration.Tests.ps1
│   │   ├── Network-Management.Tests.ps1
│   │   ├── Security.Tests.ps1
│   │   ├── Development-Tools.Tests.ps1
│   │   └── Automation.Tests.ps1
│   ├── Integration/                   # Integration and end-to-end tests
│   │   └── End-to-End.Tests.ps1
│   └── TestHelpers/                   # Shared test utilities
│       └── TestSetup.ps1
├── TestResults/                       # Test output and reports
├── RunTests.ps1                       # Main test runner
├── pester.config.ps1                  # Pester configuration
└── TESTING.md                         # This documentation
```

## Test Types

### Unit Tests

Unit tests verify individual functions and components work correctly in isolation:

- **Script Validation**: Syntax checking and help validation
- **Parameter Validation**: Input validation and error handling
- **Core Functionality**: Main script logic and output validation
- **Error Handling**: Exception handling and edge cases
- **Performance**: Execution time and resource usage

Example unit test:
```powershell
Describe "Get-SystemInfo.ps1" {
    Context "Parameter validation" {
        It "should accept valid computer names" {
            { Get-SystemInfo -ComputerName "localhost" -WhatIf } | Should -Not -Throw
        }
    }
    
    Context "Output format validation" {
        It "should return system information object" {
            $result = Get-SystemInfo -ComputerName "localhost"
            $result | Should -Not -BeNullOrEmpty
            $result.ComputerName | Should -Be "TEST-COMPUTER"
        }
    }
}
```

### Integration Tests

Integration tests verify complete workflows and cross-script functionality:

- **Cross-script Integration**: Scripts working together
- **Realistic Scenarios**: Real-world usage patterns
- **End-to-end Workflows**: Complete business processes
- **Error Propagation**: How errors cascade between scripts

Example integration test:
```powershell
Describe "End-to-End Integration Tests" {
    Context "Cross-script functionality" {
        It "should generate system report and schedule task to run it" {
            # Create system report
            $systemInfo = Get-SystemInfo -ComputerName "localhost"
            $systemInfo | Should -Not -BeNullOrEmpty
            
            # Schedule task to run report
            $task = New-ScheduledTask -TaskName "SystemReportTask" -ScriptPath $script:SystemInfoScript
            $task | Should -Not -BeNullOrEmpty
        }
    }
}
```

## Test Helpers

The `TestSetup.ps1` file provides common utilities:

- **Environment Setup**: Initialize and clean up test environment
- **Mock Helpers**: Common mock objects and responses
- **Test Data**: Generate test data and fixtures
- **Validation Helpers**: Common validation functions

## Configuration

### Pester Configuration

The `pester.config.ps1` file contains:

- Test discovery paths
- Code coverage settings
- Output formats and paths
- Coverage thresholds (80% target)
- Verbosity and reporting options

### Test Runner Options

The `RunTests.ps1` script supports:

- **TestType**: All, Unit, Integration
- **OutputFormat**: NUnitXml, JUnitXml, Console
- **ShowDetails**: Detailed output
- **CI**: Continuous integration mode with coverage

## CI/CD Integration

### GitHub Actions

The `.github/workflows/test.yml` workflow:

- Runs on Windows with PowerShell 5.1 and 7.x
- Executes syntax validation
- Runs unit and integration tests
- Generates code coverage reports
- Performs security analysis with PSScriptAnalyzer
- Uploads test results and coverage data

### Test Reports

Tests generate multiple report formats:

- **NUnit XML**: For CI/CD integration
- **JUnit XML**: For test reporting systems
- **JaCoCo XML**: For code coverage
- **Console**: For local development

## Best Practices

### Writing Tests

1. **Test Structure**:
   - Use descriptive `Describe`, `Context`, and `It` blocks
   - Group related tests logically
   - Use meaningful test names that describe expected behavior

2. **Test Isolation**:
   - Each test should be independent
   - Use `BeforeEach` and `AfterEach` for setup/cleanup
   - Mock external dependencies

3. **Assertions**:
   - Use specific assertions (`Should -Be`, `Should -Contain`)
   - Test both positive and negative cases
   - Verify error conditions

4. **Mock Strategy**:
   - Mock external dependencies (CIM, network, file system)
   - Use realistic mock data
   - Verify mock interactions when needed

### Test Maintenance

1. **Keep Tests Updated**:
   - Update tests when functionality changes
   - Add tests for new features
   - Remove obsolete tests

2. **Test Performance**:
   - Keep tests fast (< 30 seconds for unit tests)
   - Use timeouts for network operations
   - Optimize slow tests

3. **Test Coverage**:
   - Aim for 80%+ code coverage
   - Focus on critical paths
   - Test error handling paths

## Security Testing

### Automated Security Checks

The framework includes automated security analysis:

- **PSScriptAnalyzer**: Static code analysis
- **Credential Scanning**: Detect hardcoded passwords
- **Dangerous Cmdlet Detection**: Identify risky operations
- **External URL Scanning**: Find external dependencies

### Security Test Guidelines

1. **Test Security Features**:
   - Verify encryption/decryption
   - Test password generation
   - Validate secure storage

2. **Test Error Handling**:
   - Verify no secrets in error messages
   - Test permission denied scenarios
   - Validate input sanitization

## Troubleshooting

### Common Issues

1. **Pester Not Found**:
   ```powershell
   Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
   ```

2. **Test Failures**:
   - Check test output for specific errors
   - Run with `-ShowDetails` for more information
   - Verify script syntax with PowerShell parser

3. **Coverage Issues**:
   - Ensure all scripts are in coverage paths
   - Check for excluded files
   - Verify test execution actually calls functions

### Debug Mode

For debugging tests:

```powershell
# Run specific test file
Invoke-Pester -Path ".\Tests\Unit\System-Administration.Tests.ps1" -Output Detailed

# Run specific test
Invoke-Pester -Path ".\Tests\Unit\System-Administration.Tests.ps1" -FullName "*should accept valid computer names*"
```

## Contributing

When adding new scripts or features:

1. **Write Tests First**: Use TDD approach when possible
2. **Maintain Coverage**: Ensure new code is tested
3. **Update Documentation**: Keep this file updated
4. **Run Full Test Suite**: Verify all tests pass before committing

## Performance Benchmarks

Target performance goals:

- **Unit Tests**: < 30 seconds total
- **Integration Tests**: < 2 minutes total
- **Full Test Suite**: < 5 minutes total
- **Individual Script Tests**: < 10 seconds each

## Future Enhancements

Planned improvements:

- **Property-based Testing**: Add randomized test data
- **Load Testing**: Test scripts with large datasets
- **Cross-platform Testing**: Linux and macOS support
- **Performance Profiling**: Detailed performance metrics
- **Mutation Testing**: Verify test quality

## Support

For testing issues:

1. Check this documentation
2. Review test output and logs
3. Check GitHub Issues for known problems
4. Create new issue with detailed error information