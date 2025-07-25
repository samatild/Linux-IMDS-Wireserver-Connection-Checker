
# Linux IMDS/Wireserver Connectivity Checker

## Overview

This repository provides a robust Bash script to check the connectivity status between an Azure Linux VM and Azure's Instance Metadata Service (IMDS) and Wireserver. The script is designed for troubleshooting and diagnostics, helping you quickly identify network or firewall issues that may affect Azure VM functionality.

- **No data is collected or changed on your machine.**
- **No ping/ICMP is used**—all checks are performed using TCP, UDP, and HTTP.
- **No additional packages required**—uses standard Linux tools.
- **All output is printed directly to the shell.**

## Features

- Checks TCP and UDP connectivity to IMDS and Wireserver on ports 80 and 443
- Verifies IMDS HTTP API availability
- Analyzes firewall (iptables) rules for relevant ports and IPs
- Displays network interface and routing information for Azure endpoints
- Color-coded, human-friendly output
- No root required for most checks (firewall checks may need sudo)
- No dependencies on ping/ICMP

## Prerequisites

- Linux VM (tested on Ubuntu, Debian, CentOS, RHEL)
- Standard utilities: `nc`, `curl`, `iptables`
- (Optional) `sudo` for firewall checks

## Usage
   ```bash
   # Download the script:
   curl -O https://raw.githubusercontent.com/samatild/linuximdswireserver-connectionchecker/main/imds-wireserver-connectivity-checker.sh

   # Make the script executable:
   chmod +x imds-wireserver-connectivity-checker.sh

   # Run the script:
   ./imds-wireserver-connectivity-checker.sh
```<

   > For firewall checks, you may be prompted for your password to run `sudo`.

## Example Output

```
=== IMDS AND WIRESERVER CONNECTIVITY CHECKER ===
ℹ Script is running as non-root user (some checks may be limited)

=== PORT CONNECTIVITY TESTS ===
✓ TCP port 80 for 169.254.169.254 (IMDS): OPEN
✓ TCP port 443 for 169.254.169.254 (IMDS): OPEN
✓ UDP port 80 for 169.254.169.254 (IMDS): OPEN
✗ UDP port 443 for 169.254.169.254 (IMDS): CLOSED
...
=== IMDS API TEST ===
✓ IMDS HTTP API: RESPONDING (HTTP 200)
...
=== SUMMARY REPORT ===
ℹ Total tests: 8
✓ Passed: 7
✗ Failed: 1
```

## Troubleshooting

- **Missing tools:** If you see a message about missing tools, install them using your package manager. For example:
  ```bash
  sudo apt-get install netcat-openbsd curl iptables
  ```
- **Firewall checks require sudo:** If you run as a non-root user, you may be prompted for your password.
- **Script exits early:** Ensure you are using the latest version of the script. If you modified the script, make sure all test sections are present.

## Reference Documents

- [Overview of Azure's Instance Metadata Service](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/instance-metadata-service)
- [Understanding Azure's Wireserver](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/instance-metadata-service)

## License

This project is licensed under the terms of the MIT license. For more details, see the [LICENSE](LICENSE) file.