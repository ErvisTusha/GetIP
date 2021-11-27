#!/bin/bash

COLOR_OFF='\033[0m' # Text Reset
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
NC=$'\e[0m'         # No Color
BOLD=$(tput bold)



echo "Github Repository https://github.com/ErvisTusha/CTF-IP"
echo -e "Creator: ${RED}${BOLD} Ervis Tusha ${NC}  Contact : ${RED}${BOLD}https://twitter.com/ET ${NC} \n"

#get tun0 ip
ipAddr=$( ip a s tun0  | awk -F"[ /]+" '/scope global/{print $3}' )

if [ $ipAddr ]; then
    #Show VPN tun0 IP
    echo -e "${GREEN}${BOLD}\n\n     tun0 IP: " $ipAddr"  \n\n "
else
    #Error Message
    echo -e "${RED}${BOLD}\n\n    Please connect to VPN  \n\n"
fi 
