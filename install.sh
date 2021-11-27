#!/bin/bash



COLOR_OFF='\033[0m' # Text Reset
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
NC=$'\e[0m'         # No Color
BOLD=$(tput bold)



echo "Github Repository https://github.com/ErvisTusha/CTF-IP"
echo -e "Creator: ${RED}${BOLD} Ervis Tusha ${NC}  Contact : ${RED}${BOLD}https://twitter.com/ET ${NC} \n"


if [ $EUID -ne 0 ]; then
    echo -e "You must have root permission to install.\n\n"
    exit 1
fi

cp ctf-ip.sh /usr/local/bin/ctf-ip
chmod +x /usr/local/bin/ctf-ip



if [ ! -f "/usr/local/bin/ctf-ip" ]; then
    echo -e "Failed to copy ctf-ip to /usr/local/bin/ctf-ip \n\n"
    exit 1
fi


echo -e "Installaion finished successfully \n\n"
exit 0