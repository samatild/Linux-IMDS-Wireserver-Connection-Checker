#!/bin/bash

# wire imds connectivity check
# Description: This script checks the connectivity to IMDS and Wireserver
# Author: samatild
# Date: 29/05/2023

# Test connectivity to 169.254.169.254

echo "[Checking IMDS Connectivity]"
if echo "" | nc -w1 -zv 169.254.169.254 80 &>/dev/null; then
    echo "TCP port 80 for 169.254.169.254: success"
else
    echo "TCP port 80 for 169.254.169.254: failure"
fi

if nc -w1 -zvu 169.254.169.254 80 &>/dev/null; then
    echo "UDP port 80 for 169.254.169.254: success"
else
    echo "UDP port 80 for 169.254.169.254: failure"
fi

if nc -w1 -zvu 169.254.169.254 443 &>/dev/null; then
    echo "UDP port 443 for 169.254.169.254: success"
else
    echo "UDP port 443 for 169.254.169.254: failure"
fi

echo ""

# Test connectivity to 168.63.129.16
echo "[Checking Wireserver Connectivity]"
if echo "" | nc -w1 -zv 168.63.129.16 80 &>/dev/null; then
    echo "TCP port 80 for 168.63.129.16: success"
else
    echo "TCP port 80 for 168.63.129.16: failure"
fi

if nc -w1 -zvu 168.63.129.16 80 &>/dev/null; then
    echo "UDP port 80 for 168.63.129.16: success"
else
    echo "UDP port 80 for 168.63.129.16: failure"
fi

if nc -w1 -zvu 168.63.129.16 443 &>/dev/null; then
    echo "UDP port 443 for 168.63.129.16: success"
else
    echo "UDP port 443 for 168.63.129.16: failure"
fi

echo ""

# Firewall checks for Ports
echo "[Checking Firewall]"
if sudo iptables -L | grep "dpt:80" >/dev/null; then
    echo "Iptables rule(s) for port 80:"
    sudo iptables -L  | grep "dpt:80"
else
    echo "There is no iptables rule for port 80"
fi

if sudo iptables -L | grep "dpt:443" >/dev/null; then
    echo "Iptables rule(s) for port 443:"
    sudo iptables -L  | grep "dpt:443"
else
    echo "There is no iptables rule for port 443"
fi

echo ""

# Firewall checks for IP Addresses
if sudo iptables -L | grep "168.63.129.16" >/dev/null; then
    echo "Iptables rule(s) for IP address 168.63.129.16:"
    sudo iptables -L  | grep "168.63.129.16"
else
    echo "There is no iptables rule for IP address 168.63.129.16"
fi

if sudo iptables -L | grep "169.254.169.254" >/dev/null; then
    echo "Iptables rule(s) for IP address 169.254.169.254:"
    sudo iptables -L  | grep "169.254.169.254"
else
    echo "There is no iptables rule for IP address 169.254.169.254"
fi

# Specific to very common issues
echo "IPTABLES Security table:"
iptables -t security -L -n -v