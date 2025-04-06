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

## Installation

1. Clone or download this repository to your local machine.
2. Ensure PowerShell execution policy allows running the scripts:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
3. Navigate to the script directory and run the desired script with appropriate parameters.

## Contributing

Contributions to this toolkit are welcome! If you have improvements, bug fixes, or new scripts to add, please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

404RX

## Acknowledgments

- Microsoft PowerShell Team for the amazing scripting language
- The PowerShell community for inspiration and best practices
- Scripts and documentation created with assistance from Claude AI (Anthropic)
