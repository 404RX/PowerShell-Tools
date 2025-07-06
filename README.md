# PowerShell Toolkit

A comprehensive collection of PowerShell scripts for system administration, network management, security, development, and automation tasks.

## Overview

This toolkit provides a set of powerful PowerShell scripts designed to help IT professionals, system administrators, developers, and power users automate common tasks and improve productivity. Each script is well-documented with detailed help information, examples, and parameter descriptions.

## Categories

### System Administration

Scripts for managing and monitoring Windows systems.

- **[Get-SystemInfo.ps1](System-Administration/Get-SystemInfo.ps1)**: Retrieves comprehensive system information from local or remote computers, including hardware, operating system, installed software, and network configuration.

### Network Management

Scripts for network scanning, monitoring, and configuration.

- **[Scan-Network.ps1](Network-Management/Scan-Network.ps1)**: Scans a network range for active hosts and open ports, providing detailed information about discovered devices.

### Security

Scripts for password management, security auditing, and hardening.

- **[Password-Manager.ps1](Security/Password-Manager.ps1)**: A secure password generator and manager that can create strong passwords and securely store them using Windows Data Protection API (DPAPI).

### Development Tools

Scripts to assist with software development tasks.

- **[Generate-Code.ps1](Development-Tools/Generate-Code.ps1)**: Generates code templates and boilerplate for different programming languages and frameworks, saving time when starting new projects.

### Automation

Scripts for task scheduling and process automation.

- **[Schedule-Tasks.ps1](Automation/Schedule-Tasks.ps1)**: Simplifies the creation and management of scheduled tasks on Windows systems, providing an easy-to-use interface for common scheduling operations.

## Usage

Each script includes detailed help information that can be accessed using the PowerShell `Get-Help` cmdlet:

```powershell
Get-Help .\Script-Name.ps1 -Full
```

Most scripts also include examples in their header comments that demonstrate common usage scenarios.

## Requirements

- PowerShell 5.1 or later
- Windows 10/11 or Windows Server 2016/2019/2022
- Administrator privileges for some operations

## Testing

This repository includes a comprehensive testing framework using **Pester** to ensure all scripts work correctly and maintain high code quality.

### Quick Start Testing

```powershell
# Run all tests
.\RunTests.ps1

# Run with detailed output
.\RunTests.ps1 -ShowDetails

# Run in CI mode with coverage
.\RunTests.ps1 -TestType All -OutputFormat NUnitXml -CI

# Run only unit tests
.\RunTests.ps1 -TestType Unit

# Run only integration tests
.\RunTests.ps1 -TestType Integration
```

### Test Framework Features

- **Unit Tests**: Test individual script components in isolation
- **Integration Tests**: Test complete workflows and cross-script functionality
- **Code Coverage**: Maintains 80%+ test coverage across all scripts
- **Security Analysis**: Automated security scanning with PSScriptAnalyzer
- **CI/CD Integration**: Automated testing on every commit and pull request
- **Performance Testing**: Validates script execution time and resource usage

### Test Results

The testing framework generates comprehensive reports:
- **Console Output**: Real-time test results
- **NUnit XML**: For CI/CD integration
- **Code Coverage Reports**: JaCoCo format for coverage analysis
- **Security Reports**: Potential security issues and recommendations

For detailed testing information, see [TESTING.md](TESTING.md).

## Installation

1. Clone or download this repository to your local machine.
2. Ensure PowerShell execution policy allows running the scripts:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Navigate to the script directory and run the desired script with appropriate parameters.
4. **(Optional)** Install Pester for running tests:
   ```powershell
   Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
   ```

## Quality Assurance

### Automated Testing

All scripts are validated through:
- **Syntax Validation**: PowerShell parser verification
- **Unit Testing**: Individual component testing
- **Integration Testing**: End-to-end workflow validation
- **Security Scanning**: PSScriptAnalyzer static analysis
- **Performance Testing**: Execution time and resource usage validation

### Branch Protection

This repository enforces quality standards through:
- **Required Tests**: All PRs must pass the complete test suite
- **Code Coverage**: Maintain 80%+ test coverage
- **Security Review**: Automated security analysis on all changes
- **Peer Review**: All changes require code review before merging

## Contributing

We welcome contributions to this PowerShell toolkit! To ensure high quality and maintainability, please follow these guidelines:

### 🚀 Quick Start for Contributors

1. **Fork the repository** and create a feature branch
2. **Run existing tests** to ensure your environment is set up correctly:
   ```powershell
   .\RunTests.ps1 -ShowDetails
   ```
3. **Make your changes** following PowerShell best practices
4. **Write tests** for new functionality (see [TESTING.md](TESTING.md))
5. **Run all tests** to ensure nothing is broken:
   ```powershell
   .\RunTests.ps1 -CI
   ```
6. **Submit a pull request** with a clear description of your changes

### 📋 Contribution Requirements

#### **All Contributions Must Include:**
- ✅ **Unit Tests**: Test individual functions and components
- ✅ **Integration Tests**: Test complete workflows (if applicable)
- ✅ **Documentation**: Update help text and examples
- ✅ **Security Review**: Ensure no security vulnerabilities
- ✅ **Performance Validation**: Verify reasonable execution times

#### **Code Quality Standards:**
- ✅ **PowerShell Best Practices**: Follow established conventions
- ✅ **Parameter Validation**: Include proper input validation
- ✅ **Error Handling**: Implement comprehensive error handling
- ✅ **Help Documentation**: Include detailed help text with examples
- ✅ **Security Considerations**: No hardcoded credentials or unsafe operations

#### **Testing Requirements:**
- ✅ **80%+ Code Coverage**: Maintain or improve test coverage
- ✅ **All Tests Pass**: Both unit and integration tests must pass
- ✅ **Mock External Dependencies**: Mock CIM, network, file system operations
- ✅ **Performance Tests**: Validate execution time requirements

### 🔧 Development Workflow

1. **Clone and Setup**:
   ```powershell
   git clone https://github.com/404RX/PowerShell-Tools.git
   cd PowerShell-Tools
   .\RunTests.ps1  # Verify setup
   ```

2. **Create Feature Branch**:
   ```powershell
   git checkout -b feature/your-feature-name
   ```

3. **Development Cycle**:
   ```powershell
   # Make changes
   # Write tests
   .\RunTests.ps1 -TestType Unit  # Quick validation
   .\RunTests.ps1 -CI             # Full validation
   ```

4. **Before Submitting**:
   ```powershell
   # Final validation
   .\RunTests.ps1 -TestType All -ShowDetails
   
   # Check test coverage
   .\RunTests.ps1 -CI
   ```

### 🛡️ Security Guidelines

- **Never commit secrets**: No passwords, API keys, or sensitive data
- **Use secure practices**: Leverage Windows DPAPI for credential storage
- **Validate inputs**: Sanitize all user inputs and parameters
- **Review dependencies**: Ensure all external calls are necessary and secure
- **Document security considerations**: Explain any security-related decisions

### 📝 Pull Request Process

1. **Ensure all tests pass** locally before submitting
2. **Update documentation** for any new features or changes
3. **Include test results** in your PR description
4. **Provide clear description** of what your changes do and why
5. **Reference issues** if your PR addresses existing issues
6. **Be responsive** to code review feedback

### 🏷️ Commit Message Guidelines

Use clear, descriptive commit messages:
```
Add network latency monitoring to Scan-Network.ps1

- Include ping response time measurement
- Add timeout configuration parameter
- Update unit tests for new functionality
- Add integration test for latency monitoring

Tests: All unit and integration tests pass
Coverage: Maintains 85% code coverage
```

### 🐛 Bug Reports

When reporting bugs:
1. **Use the issue template** (if available)
2. **Include PowerShell version** and operating system
3. **Provide script output** and error messages
4. **Include test results** if applicable
5. **Describe expected vs actual behavior**

### 💡 Feature Requests

For new features:
1. **Describe the use case** and business value
2. **Provide implementation suggestions** if you have them
3. **Consider backward compatibility** implications
4. **Discuss testing approach** for the new feature

### 🎯 Areas for Contribution

We're particularly interested in:
- **Cross-platform support**: Making scripts work on Linux/macOS
- **Performance improvements**: Optimizing script execution
- **Additional test scenarios**: Edge cases and error conditions
- **Documentation improvements**: Better examples and explanations
- **Security enhancements**: Additional security validations
- **New script categories**: Expanding the toolkit's capabilities

### 🤝 Code Review Process

All pull requests undergo:
1. **Automated testing**: GitHub Actions CI/CD pipeline
2. **Security analysis**: PSScriptAnalyzer and manual review
3. **Code quality review**: Maintainer review of code and tests
4. **Documentation review**: Ensure adequate documentation
5. **Performance review**: Validate execution time requirements

### 📞 Getting Help

- **Documentation**: Start with [TESTING.md](TESTING.md) for testing help
- **Issues**: Create a GitHub issue for bugs or questions
- **Discussions**: Use GitHub Discussions for general questions
- **Code Review**: Maintainers will provide feedback on PRs

Thank you for contributing to PowerShell-Tools! Your contributions help make this toolkit better for the entire PowerShell community.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

404RX

## Acknowledgments

- Microsoft PowerShell Team for the amazing scripting language
- The PowerShell community for inspiration and best practices
- Scripts and documentation created with assistance from Claude AI (Anthropic)
