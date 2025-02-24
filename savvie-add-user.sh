#!/bin/bash

############################################################
# SAVVIE Proxy Installer
# Author: captainsza
# Email: info@captainsza.com
# Github: https://github.com/captainsza/SAVVIE-Proxy/
# Web: https://flexeere.com
# If you need professional assistance, reach out to
# https://flexeere.com/order/contact.php
############################################################

if [ `whoami` != root ]; then
	echo "ERROR: You need to run the script as user root or add sudo before command."
	exit 1
fi

if [ ! -f /usr/bin/htpasswd ]; then
    echo "htpasswd not found"
    exit 1
fi

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

if [[ -d /etc/squid/ || -d /etc/squid3/ ]]; then
	echo -e "${GREEN}Thank you for using SAVVIE Proxy Service.${NC}"
 	echo
    	SQUID_USER=$(cat /dev/urandom | tr -dc 'a-z' | fold -w 8 | head -n 1)
	SQUID_PW=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
	echo -e "${CYAN}Username : ${SQUID_USER}${NC}"
	echo -e "${CYAN}Password : ${SQUID_PW}${NC}"
 	echo -e "${CYAN}Port : 3128${NC}"
	
	htpasswd -b -c /etc/squid/passwd $SQUID_USER $SQUID_PW > /dev/null 2>&1
	
	sed -i 's/Squid proxy-caching web server/SAVVIE Proxy Service/g'  /etc/squid/squid.conf
	
	systemctl restart squid > /dev/null 2>&1
	systemctl restart squid3 > /dev/null 2>&1
    exit 1
fi


