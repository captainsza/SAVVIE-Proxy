#!/bin/bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "\n${YELLOW}Checking Proxy Status...${NC}"

# Get current proxy configuration
get_proxy_config() {
    # Try reading from stored credentials
    if [ -f "/etc/profile.d/proxy-credentials.sh" ]; then
        source /etc/profile.d/proxy-credentials.sh
    fi

    # Get active port
    PORT=$(netstat -tlpn | grep squid | grep -oP ':\\K\\d+' | head -1)
    
    # Get server IP
    SERVER_IP=$(curl -s ifconfig.me)

    # Try to get active credentials
    if [ -z "$PROXY_USER" ] || [ -z "$PROXY_PASS" ]; then
        if [ -f "/root/.proxy_auth" ]; then
            # Try reading from our custom auth file
            PROXY_USER=$(head -n1 /root/.proxy_auth | cut -d: -f1)
            PROXY_PASS=$(head -n1 /root/.proxy_auth | cut -d: -f2)
        elif [ -f "/etc/squid/passwd" ]; then
            # Last resort - try squid's passwd file for username
            PROXY_USER=$(head -n1 /etc/squid/passwd | cut -d: -f1)
            # Use stored password if available
            if [ -f "/etc/squid/.proxy_pass" ]; then
                PROXY_PASS=$(cat /etc/squid/.proxy_pass)
            fi
        fi
    fi

    echo "${SERVER_IP}:${PORT}:${PROXY_USER}:${PROXY_PASS}"
}

# Get configuration
CONFIG=$(get_proxy_config)
SERVER_IP=$(echo $CONFIG | cut -d: -f1)
PORT=$(echo $CONFIG | cut -d: -f2)
PROXY_USER=$(echo $CONFIG | cut -d: -f3)
PROXY_PASS=$(echo $CONFIG | cut -d: -f4)

if [ ! -z "${PORT}" ] && [ ! -z "${PROXY_USER}" ] && [ ! -z "${PROXY_PASS}" ]; then
    echo -e "\n${CYAN}Proxy Configuration Found:${NC}"
    echo -e "IP: ${GREEN}${SERVER_IP}${NC}"
    echo -e "Port: ${GREEN}${PORT}${NC}"
    echo -e "Username: ${GREEN}${PROXY_USER}${NC}"
    echo -e "Password: ${GREEN}${PROXY_PASS}${NC}"

    # Format for testing
    PROXY_STRING="${SERVER_IP}:${PORT}:${PROXY_USER}:${PROXY_PASS}"
    echo -e "\n${CYAN}Proxy String:${NC}"
    echo -e "${GREEN}${PROXY_STRING}${NC}"

    # Test locally first
    echo -e "\n${CYAN}Testing Local Connection:${NC}"
    if curl -m 5 -x "${SERVER_IP}:${PORT}" -U "${PROXY_USER}:${PROXY_PASS}" -s https://ip.me > /dev/null; then
        echo -e "${GREEN}Local Connection Successful ✓${NC}"
        EXTERNAL_IP=$(curl -m 5 -x "${SERVER_IP}:${PORT}" -U "${PROXY_USER}:${PROXY_PASS}" -s https://ip.me)
        echo -e "External IP: ${GREEN}${EXTERNAL_IP}${NC}"
        
        # Test with proxy6.net using proper API format
        echo -e "\n${CYAN}Testing with proxy6.net...${NC}"
        RESPONSE=$(curl -s -X POST "https://proxy6.net/api/check" \
            -H "Content-Type: application/json" \
            -d "{\"proxy\":\"${PROXY_STRING}\"}")

        if echo "${RESPONSE}" | grep -q "\"working\":true"; then
            echo -e "${GREEN}Proxy6.net Check Passed ✓${NC}"
            SPEED=$(echo "${RESPONSE}" | grep -o '"response_time":[0-9]*' | cut -d: -f2)
            echo -e "Response Time: ${SPEED}ms"
        else
            echo -e "${RED}Proxy6.net Check Failed ✗${NC}"
        fi
    else
        echo -e "${RED}Local Connection Failed ✗${NC}"
    fi
else
    echo -e "\n${RED}Proxy configuration incomplete:${NC}"
    echo -e "Port: ${PORT:-Missing}"
    echo -e "Username: ${PROXY_USER:-Missing}"
    echo -e "Password: ${PROXY_PASS:-Missing}"
fi
