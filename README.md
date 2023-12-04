
# Linux IMDS/Wireserver Connectivity Checker

## Description

This repository contains a small script that checks the connectivity status between an Azure Linux VM and Azure's Instance Metadata Service (IMDS) and Wireserver. 
By executing the script, you agree to the terms of the [MIT license](LICENSE). The script itself doesn't collect or change any data on your machine.
The script doens't require any additional packages to be installed and can be run directly on the VM.

## Usage

Just follow the steps below to run the script:

```bash
# Download the script
$ wget https://raw.githubusercontent.com/azure/azure-linux-imds-wireserver-connectivity-checker/master/imds-wireserver-connectivity-checker.sh

# Make the script executable
$ chmod +x imds-wireserver-connectivity-checker.sh

# Run the script
$ ./imds-wireserver-connectivity-checker.sh
```

## Reference Documents

For more information on Azure's IMDS and Wireserver, please refer to the following documents:

- [Overview of Azure's Instance Metadata Service](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/instance-metadata-service)
- [Understanding Azure's Wireserver](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/instance-metadata-service)

## License

This project is licensed under the terms of the MIT license. For more details, see the [LICENSE](LICENSE) file.