
# Linux IMDS/Wireserver Connectivity Checker

## Overview
- Bash script to check Azure Linux VM connectivity to IMDS and Wireserver.
- No data is collected or changed.
- No ping/ICMP used; all output is printed to the shell.

## Features
- TCP/UDP connectivity checks (ports 80, 443) for IMDS and Wireserver
- IMDS HTTP API test
- Firewall (iptables) and network diagnostics
- Color-coded, human-friendly output

## Prerequisites
- Linux VM with `nc`, `curl`, `iptables`
- (Optional) `sudo` for firewall checks

## Usage

    # Download the script:
    curl -O https://raw.githubusercontent.com/samatild/linuximdswireserver-connectionchecker/main/imds-wireserver-connectivity-checker.sh

    # Make the script executable:
    chmod +x imds-wireserver-connectivity-checker.sh

    # Run the script:
    ./imds-wireserver-connectivity-checker.sh

   > For firewall checks, you may be prompted for your password to run `sudo`.

## Example Output

```bash
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

- **Missing tools:** Install with your package manager, e.g.:
  ```bash
  sudo apt-get install netcat-openbsd curl iptables
  ```
- **Firewall checks require sudo:** You may be prompted for your password.
- **Script exits early:** Use the latest script version and ensure all test sections are present.

## Reference Documents

- [Overview of Azure's Instance Metadata Service](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/instance-metadata-service)
- [Understanding Azure's Wireserver](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/instance-metadata-service)

## License

This project is licensed under the terms of the MIT license. For more details, see the [LICENSE](LICENSE) file.