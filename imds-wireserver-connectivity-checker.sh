#!/bin/bash

# IMDS and Wireserver Connectivity Checker
# Description: Comprehensive connectivity and firewall diagnostics for Azure IMDS and Wireserver
# Author: samatild (enhanced version)
# Date: 29/05/2023
# Version: 2.0

# Configuration
readonly IMDS_IP="169.254.169.254"
readonly WIRESERVER_IP="168.63.129.16"
readonly PORTS=(80 443)
readonly TIMEOUT=5

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Print colored output
print_status() {
    local status="$1"
    local message="$2"
    case "$status" in
        "SUCCESS") echo -e "${GREEN}✓${NC} $message" ;;
        "FAILURE") echo -e "${RED}✗${NC} $message" ;;
        "WARNING") echo -e "${YELLOW}⚠${NC} $message" ;;
        "INFO") echo -e "${BLUE}ℹ${NC} $message" ;;
        "HEADER") echo -e "${CYAN}===${NC} $message ${CYAN}===${NC}" ;;
    esac
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_status "WARNING" "Script is running as root"
    else
        print_status "INFO" "Script is running as non-root user (some checks may be limited)"
    fi
}

# Check if required tools are available
check_dependencies() {
    local missing_tools=()
    
    for tool in nc curl iptables; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        print_status "FAILURE" "Missing required tools: ${missing_tools[*]}"
        print_status "INFO" "Please install: apt-get install netcat-openbsd curl iputils-ping iptables"
        exit 1
    fi
}

# Test TCP connectivity
test_tcp_connectivity() {
    local ip="$1"
    local port="$2"
    local description="$3"
    
    if timeout "$TIMEOUT" bash -c "</dev/tcp/$ip/$port" 2>/dev/null; then
        print_status "SUCCESS" "TCP port $port for $ip ($description): OPEN"
        return 0
    else
        print_status "FAILURE" "TCP port $port for $ip ($description): CLOSED"
        return 1
    fi
}

# Test UDP connectivity
test_udp_connectivity() {
    local ip="$1"
    local port="$2"
    local description="$3"
    
    if timeout "$TIMEOUT" nc -zvu "$ip" "$port" &>/dev/null; then
        print_status "SUCCESS" "UDP port $port for $ip ($description): OPEN"
        return 0
    else
        print_status "FAILURE" "UDP port $port for $ip ($description): CLOSED"
        return 1
    fi
}

# Test HTTP connectivity to IMDS
test_imds_http() {
    local response
    if response=$(timeout "$TIMEOUT" curl -s -w "%{http_code}" -o /dev/null "http://$IMDS_IP/metadata/instance?api-version=2021-02-01" 2>/dev/null); then
        if [[ "$response" == "200" ]]; then
            print_status "SUCCESS" "IMDS HTTP API: RESPONDING (HTTP $response)"
            return 0
        else
            print_status "WARNING" "IMDS HTTP API: RESPONDING (HTTP $response) - unexpected status"
            return 1
        fi
    else
        print_status "FAILURE" "IMDS HTTP API: NOT RESPONDING"
        return 1
    fi
}

# Check iptables rules
check_iptables_rules() {
    local target="$1"
    local description="$2"
    
    if sudo iptables -L -n | grep -q "$target"; then
        print_status "WARNING" "Iptables rules found for $description:"
        sudo iptables -L -n | grep "$target" | while read -r line; do
            echo "  $line"
        done
        return 0
    else
        print_status "SUCCESS" "No iptables rules found for $description"
        return 0
    fi
}

# Check security table
check_security_table() {
    print_status "INFO" "Checking iptables security table..."
    if sudo iptables -t security -L -n -v 2>/dev/null; then
        print_status "INFO" "Security table rules displayed above"
    else
        print_status "WARNING" "Could not access security table or no rules found"
    fi
}

# Check network interfaces
check_network_interfaces() {
    print_status "INFO" "Checking network interfaces..."
    ip addr show | grep -E "inet.*169\.254|inet.*168\.63" || print_status "WARNING" "No Azure-specific IP addresses found on interfaces"
}

# Check routing table
check_routing() {
    print_status "INFO" "Checking routing table for Azure endpoints..."
    ip route | grep -E "169\.254|168\.63" || print_status "WARNING" "No specific routes found for Azure endpoints"
}

# Generate summary report
generate_summary() {
    local total_tests=$1
    local passed_tests=$2
    local failed_tests=$3
    
    echo
    print_status "HEADER" "SUMMARY REPORT"
    print_status "INFO" "Total tests: $total_tests"
    print_status "SUCCESS" "Passed: $passed_tests"
    print_status "FAILURE" "Failed: $failed_tests"
    
    if [[ $failed_tests -eq 0 ]]; then
        print_status "SUCCESS" "All connectivity tests passed!"
    else
        print_status "WARNING" "Some connectivity issues detected."
    fi
}

# Main execution
main() {
    local total_tests=0
    local passed_tests=0
    local failed_tests=0
    
    print_status "HEADER" "IMDS AND WIRESERVER CONNECTIVITY CHECKER"
    
    # Pre-flight checks
    check_root
    check_dependencies
    
    echo
    print_status "HEADER" "BASIC CONNECTIVITY TESTS"
    
    # Ping tests
    if test_tcp_connectivity "$IMDS_IP" "80" "IMDS"; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
    
    if test_tcp_connectivity "$WIRESERVER_IP" "80" "Wireserver"; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
    
    echo
    print_status "HEADER" "PORT CONNECTIVITY TESTS"
    
    # TCP connectivity tests
    for port in "${PORTS[@]}"; do
        if test_tcp_connectivity "$IMDS_IP" "$port" "IMDS"; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
        
        if test_tcp_connectivity "$WIRESERVER_IP" "$port" "Wireserver"; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    done
    
    # UDP connectivity tests
    for port in "${PORTS[@]}"; do
        if test_udp_connectivity "$IMDS_IP" "$port" "IMDS"; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
        
        if test_udp_connectivity "$WIRESERVER_IP" "$port" "Wireserver"; then
            ((passed_tests++))
        else
            ((failed_tests++))
        fi
        ((total_tests++))
    done
    
    echo
    print_status "HEADER" "IMDS API TEST"
    
    # IMDS HTTP API test
    if test_imds_http; then
        ((passed_tests++))
    else
        ((failed_tests++))
    fi
    ((total_tests++))
    
    echo
    print_status "HEADER" "NETWORK DIAGNOSTICS"
    
    # Network diagnostics
    check_network_interfaces
    check_routing
    
    echo
    print_status "HEADER" "FIREWALL ANALYSIS"
    
    # Firewall checks
    check_iptables_rules "dpt:80" "port 80"
    check_iptables_rules "dpt:443" "port 443"
    check_iptables_rules "$IMDS_IP" "IMDS IP"
    check_iptables_rules "$WIRESERVER_IP" "Wireserver IP"
    check_security_table
    
    # Generate summary
    generate_summary "$total_tests" "$passed_tests" "$failed_tests"
    
    # Exit with appropriate code
    if [[ $failed_tests -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

# Handle script interruption
trap 'echo -e "\n${YELLOW}Script interrupted by user${NC}"; exit 130' INT TERM

# Run main function
main "$@"