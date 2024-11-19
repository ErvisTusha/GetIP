#!/bin/bash

#==============================================================================
# GetIP - Network Interface IP Tool
#==============================================================================
# Purpose:
#   A tool to easily retrieve and display IP addresses for network interfaces
#   with support for both IPv4 and IPv6 addresses. Features include listing
#   all interfaces, raw output mode, and specific interface querying.
#
# Usage:
#   ./getip.sh [options] [interface]
#   See --help for detailed usage information
#
# Requirements:
#   - bash shell
#   - iproute2 package (ip command)
#   - gawk package (awk command)
#
# Author:
#   Ervis Tusha <https://x.com/ET>
#   https://github.com/ErvisTusha/GetIP
#
# License:
#   MIT License
#   Copyright (c) 2024 Ervis Tusha
#   See LICENSE file for details
#==============================================================================

COLOR_OFF='\033[0m' # Text Reset
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
NC='\033[0m'        # No Color
BOLD='\033[1m'      # Bold
CYAN='\033[0;36m'   # Cyan
YELLOW='\033[1;33m' # Yellow

# Constants
VERSION="1.1.0"
AUTHOR="Ervis Tusha"
SCRIPT=$(basename "$0")
RAW_OUTPUT=false
REPO_URL="https://raw.githubusercontent.com/ErvisTusha/GetIP/main/getip.sh"

# CHECK_DEPENDENCIES - Verifies required system commands are available
# Parameters:
#   None
# Returns:
#   Exits with 1 if dependencies are missing
CHECK_DEPENDENCIES() {
    if ! command -v ip &>/dev/null; then
        echo -e "\n${RED}${BOLD}Error:${NC} ${BOLD}ip${NC} ${RED}command not found. Please install iproute2 package\n"
        exit 1
    fi
    if ! command -v awk &>/dev/null; then
        echo -e "\n${RED}${BOLD}Error:${NC} ${BOLD}awk${NC} ${RED}command not found. Please install gawk package\n"
        exit 1
    fi
}

# SHOW_VERSION - Displays script version, banner and author information
# Parameters:
#   None
# Returns:
#   Prints version information to stdout
SHOW_VERSION() {
    BANNER="\n    
    ███████╗  ███████╗ ╔███████╗    ██╗██████╗ 
    ██╔════╝  ██╔════╝ ╚══██╔══╝    ██║██╔══██╗
    ██║  ███╗ █████╗      ██║       ██║██████╔╝
    ██║   ██║ ██╔══╝      ██║       ██║██╔═══╝ 
    ╚██████╔╝ ███████╗    ██║       ██║██║     
     ╚═════╝  ╚══════╝    ╚═╝       ╚═╝╚═╝  "

    echo -e "${BANNER}"
    echo -e "\n${GREEN}${BOLD}GetIP${NC} v${VERSION} - ${CYAN}${BOLD}Network Interface IP Tool${NC}"
    echo -e "${GREEN}${BOLD}GitHub${NC}: ${CYAN}${BOLD}https://github.com/ErvisTusha/GetIP${NC}"
    echo -e "${GREEN}${BOLD}Author${NC}: ${RED}${BOLD}${AUTHOR}${NC}    ${GREEN}${BOLD}X${NC}: ${RED}${BOLD}https://x.com/ET${NC}"

    CHECK_DEPENDENCIES
}

# SHOW_HELP - Displays usage information and command options
# Parameters:
#   None
# Returns:
#   Prints help message to stdout
SHOW_HELP() {
    echo -e "\n${BOLD}Usage:${NC}"
    echo -e "  ${CYAN}${BOLD}$SCRIPT${NC} [options]"
    echo -e "\n${BOLD}Options:${NC}"
    echo -e "  ${GREEN}${BOLD}-h, --help${NC}     Show this help message"
    echo -e "  ${GREEN}${BOLD}-v, --version${NC}  Show version information"
    echo -e "  ${GREEN}${BOLD}-l, --list${NC}     List all network interfaces"
    echo -e "  ${GREEN}${BOLD}--raw${NC}          Display IP addresses only (no formatting)"
    echo -e "  ${GREEN}${BOLD}-4${NC}             Show IPv4 address (default)"
    echo -e "  ${GREEN}${BOLD}-6${NC}             Show IPv6 address"
    echo -e "  ${CYAN}${BOLD}$SCRIPT${NC} <interface> Show IP for specific interface"
    echo -e "  ${GREEN}${BOLD}install${NC}        Install script to /usr/local/bin"
    echo -e "  ${GREEN}${BOLD}update${NC}         Update to latest version"
    echo -e "  ${GREEN}${BOLD}uninstall${NC}      Remove script from system"
    echo -e "\n${BOLD}Examples:${NC}"
    echo -e "  ${CYAN}${BOLD}$SCRIPT${NC}         Show tun0 IP"
    echo -e "  ${CYAN}${BOLD}$SCRIPT${NC} -l      List all interfaces"
    echo -e "  ${CYAN}${BOLD}$SCRIPT${NC} --raw   Show IP only"
    echo -e "  ${CYAN}${BOLD}$SCRIPT${NC} eth0    Show eth0 IP\n"
}

# LIST_INTERFACES - Shows all available network interfaces and their status
# Parameters:
#   None
# Returns:
#   Prints interface list with status and IP addresses
LIST_INTERFACES() {
    echo -e "\n${CYAN}${BOLD}Available Network Interfaces:${NC}\n"
    ip -brief link show | while read -r LINE; do
        INTERFACE=$(echo "$LINE" | awk '{print $1}')
        STATUS=$(echo "$LINE" | awk '{print $2}')
        IPV4_ADDR=$(ip -4 -brief addr show "$INTERFACE" 2>/dev/null | awk '{print $3}')
        IPV6_ADDR=$(ip -6 -brief addr show "$INTERFACE" 2>/dev/null | awk '{print $3}')

        if [ "$STATUS" = "UP" ]; then
            STATUS_COLOR=$GREEN
        else
            STATUS_COLOR=$RED
        fi

        echo -e "${WHITE}${BOLD}$INTERFACE${NC} [${STATUS_COLOR}${BOLD}$STATUS${NC}]"
        if [ -n "$IPV4_ADDR" ]; then
            echo -e "  IPv4: $IPV4_ADDR"
        else
            echo -e "  IPv4: ${YELLOW}No IPv4${NC}"
        fi
        if [ -n "$IPV6_ADDR" ]; then
            echo -e "  IPv6: $IPV6_ADDR"
        else
            echo -e "  IPv6: ${YELLOW}No IPv6${NC}"
        fi
    done
    echo
}

# GET_INTERFACE_IP - Retrieves IP addresses for a network interface
# Parameters:
#   $1 - Interface name
#   $2 - Show both IPv4/IPv6 (default: false)
#   $3 - IP version (4 or 6, default: 4)
# Returns:
#   Prints IP address(es) to stdout
GET_INTERFACE_IP() {
    local INTERFACE="$1"
    local SHOW_BOTH="${2:-false}"  # New parameter to show both IPs
    local IP_VERSION="${3:-4}"     # Still keep IP version for single IP requests

    if [ "$SHOW_BOTH" = true ]; then
        # Get both IPv4 and IPv6
        local IPV4_ADDR=$(ip -4 a s "$INTERFACE" | awk -F"[ /]+" '/scope global/{print $3}' | head -n1)
        local IPV6_ADDR=$(ip -6 a s "$INTERFACE" | awk -F"[ /]+" '/scope (global|link)/{print $3}' | head -n1)
        
        if [ "$RAW_OUTPUT" = true ]; then
            [ -n "$IPV4_ADDR" ] && printf "%s " "$IPV4_ADDR"
            [ -n "$IPV6_ADDR" ] && printf "%s" "$IPV6_ADDR"
            exit 0
        else
            echo -e "\n"
            [ -n "$IPV4_ADDR" ] && echo -e "${GREEN}${BOLD}     $INTERFACE IPv4: ${NC}${BOLD}$IPV4_ADDR${NC}"
            [ -n "$IPV6_ADDR" ] && echo -e "${GREEN}${BOLD}     $INTERFACE IPv6: ${NC}${BOLD}$IPV6_ADDR${NC}"
            echo -e "\n"
        fi
        return
    fi

    if [ "$IP_VERSION" = "4" ]; then
        local IP_ADDR=$(ip -4 a s "$INTERFACE" | awk -F"[ /]+" '/scope global/{print $3}' | head -n1)
        local IP_REGEX='^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
    else
        local IP_ADDR=$(ip -6 a s "$INTERFACE" | awk -F"[ /]+" '/scope (global|link)/{print $3}' | head -n1)
        local IP_REGEX='^([0-9a-fA-F:]+)|([0-9a-fA-F:]+%[a-zA-Z0-9]+)$'
    fi

    # Validate IP address format
    if [[ ! $IP_ADDR =~ $IP_REGEX ]]; then
        [ "$RAW_OUTPUT" = true ] && exit 1
        echo -e "${RED}${BOLD}\n\n    Invalid IPv$IP_VERSION address format\n\n"
        exit 1
    fi

    if [ "$RAW_OUTPUT" = true ]; then
        # Ensure clean output - just the IP
        if [ -n "$IP_ADDR" ]; then
            printf "%s" "$IP_ADDR"
            exit 0
        else
            exit 1
        fi
    else
        if [ -n "$IP_ADDR" ]; then
            echo -e "${GREEN}${BOLD}\n\n     $INTERFACE IPv$IP_VERSION: " $IP_ADDR"  \n\n "
        else
            echo -e "${RED}${BOLD}\n\n    No IPv$IP_VERSION address found for $INTERFACE  \n\n"
        fi
    fi
}

# INSTALL_SCRIPT - Installs the script to /usr/local/bin
# Parameters:
#   None
# Returns:
#   0 on success, 1 on failure
INSTALL_SCRIPT() {
    echo -e "\n${CYAN}${BOLD}Installing getip...${NC}"
    if [ -f "/usr/local/bin/getip" ]; then
        echo -e "${YELLOW}${BOLD}getip is already installed. Use 'update' to upgrade.${NC}\n"
        exit 0
    fi
    
    # Check if we have sudo access
    if ! sudo -v &>/dev/null; then
        echo -e "${RED}${BOLD}Error: Sudo access required for installation${NC}\n"
        exit 1
    fi
    
    # Use install command for secure copy with proper permissions
    if sudo install -m 0755 -o root -g root "$0" /usr/local/bin/getip; then
        echo -e "${GREEN}${BOLD}Successfully installed getip to /usr/local/bin/getip${NC}"
        echo -e "You can now run 'getip' from anywhere\n"
    else
        echo -e "${RED}${BOLD}Failed to install getip${NC}\n"
        exit 1
    fi
}

# UPDATE_SCRIPT - Updates the script from the repository
# Parameters:
#   None
# Returns:
#   0 on success, 1 on failure
UPDATE_SCRIPT() {
    echo -e "\n${CYAN}${BOLD}Updating getip...${NC}"
    if [ ! -f "/usr/local/bin/getip" ]; then
        echo -e "${YELLOW}${BOLD}getip is not installed. Use 'install' first.${NC}\n"
        exit 1
    fi
    TEMP_FILE=$(mktemp)
    if ! command -v curl &>/dev/null; then
        echo -e "${RED}${BOLD}Error:${NC} ${BOLD}curl${NC} ${RED}command not found. Please install curl package\n"
        exit 1
    fi

    if curl -sL "$REPO_URL" -o "$TEMP_FILE"; then
        if sudo cp "$TEMP_FILE" /usr/local/bin/getip && sudo chmod +x /usr/local/bin/getip; then
            rm "$TEMP_FILE"
            echo -e "${GREEN}${BOLD}Successfully updated getip${NC}\n"
        else
            rm "$TEMP_FILE"
            echo -e "${RED}${BOLD}Failed to update getip${NC}\n"
            exit 1
        fi
    else
        rm "$TEMP_FILE"
        echo -e "${RED}${BOLD}Failed to download update${NC}\n"
        exit 1
    fi
}

# UNINSTALL_SCRIPT - Removes the script from /usr/local/bin
# Parameters:
#   None
# Returns:
#   0 on success, 1 on failure
UNINSTALL_SCRIPT() {
    echo -e "\n${CYAN}${BOLD}Uninstalling getip...${NC}"
    if [ ! -f "/usr/local/bin/getip" ]; then
        echo -e "${YELLOW}${BOLD}getip is not installed${NC}\n"
        exit 0
    fi
    if sudo rm /usr/local/bin/getip; then
        echo -e "${GREEN}${BOLD}Successfully uninstalled getip${NC}\n"
    else
        echo -e "${RED}${BOLD}Failed to uninstall getip${NC}\n"
        exit 1
    fi
}

# Process command line arguments
case "$1" in
-h | --help)
    SHOW_VERSION
    SHOW_HELP
    exit 0
    ;;
-v | --version)
    SHOW_VERSION
    exit 0
    ;;
-l | --list)
    SHOW_VERSION
    LIST_INTERFACES
    exit 0
    ;;
--raw)
    CHECK_DEPENDENCIES
    RAW_OUTPUT=true
    if [ -n "$2" ]; then
        GET_INTERFACE_IP "$2"
    else
        SHOW_VERSION
        echo "----------------------------------------------------------------"
        echo -e "\n         ${RED}${BOLD}Error:${NC} ${BOLD}Missing interface argument\n"
        echo "----------------------------------------------------------------"
        SHOW_HELP
    fi
    ;;
    "")
        SHOW_VERSION
        LIST_INTERFACES
        ;;
    install)
        SHOW_VERSION
        INSTALL_SCRIPT
        ;;
    update)
        SHOW_VERSION
        UPDATE_SCRIPT
        ;;
    uninstall)
        SHOW_VERSION
        UNINSTALL_SCRIPT
        ;;
    *)
        IP_VERSION="4"
        INTERFACE=""
        SHOW_BOTH=true  # New default behavior

    while [[ $# -gt 0 ]]; do
        case "$1" in
        -4)
            IP_VERSION="4"
            SHOW_BOTH=false
            shift
            ;;
        -6)
            IP_VERSION="6"
            SHOW_BOTH=false
            shift
            ;;
        --raw)
            RAW_OUTPUT=true
            shift
            ;;
        *)
            INTERFACE="$1"
            shift
            ;;
        esac
    done

    if [ -n "$INTERFACE" ] && ip link show "$INTERFACE" >/dev/null 2>&1; then
        [ "$RAW_OUTPUT" = false ] && SHOW_VERSION
        GET_INTERFACE_IP "$INTERFACE" "$SHOW_BOTH" "$IP_VERSION"
    else
        SHOW_VERSION
        echo "----------------------------------------------------------------"
        echo -e "\n${RED}${BOLD}Error:${NC} ${BOLD}Invalid interface: $INTERFACE"
        echo -e "\n----------------------------------------------------------------"
        LIST_INTERFACES
        SHOW_HELP
        exit 1
    fi
    ;;
esac