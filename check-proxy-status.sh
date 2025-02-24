#!/bin/bash

# Colors and debug function
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

debug() {
    if [ "${DEBUG}" = "true" ]; then
        echo -e "${PURPLE}[DEBUG] $1${NC}"
    fi
}

debug "Script started with DEBUG=true"

echo -e "\n${YELLOW}Checking Proxy Status...${NC}"

# Get proxy configuration with debug info
get_proxy_config() {
    debug "Checking proxy configuration sources..."

    # Debug: Check if credential file exists
    if [ -f "/etc/profile.d/proxy-credentials.sh" ]; then
        debug "Found proxy-credentials.sh, sourcing it..."
        source /etc/profile.d/proxy-credentials.sh
        debug "After sourcing: PROXY_USER=$PROXY_USER, PROXY_PASS length=${#PROXY_PASS}"
    fi

    # Get port with debug info
    PORT=$(netstat -tlpn | grep -E 'squid|squid3' | grep -oP ':\K\d+' | head -1)
    debug "Detected PORT=$PORT"
    
    # Get server IP with debug
    SERVER_IP=$(curl -s ifconfig.me)
    debug "Detected SERVER_IP=$SERVER_IP"

    # Try multiple credential sources
    if [ -z "${PROXY_USER}" ] || [ -z "${PROXY_PASS}" ]; then
        debug "Credentials not found in environment, checking password files..."
        
        if [ -f "/etc/squid/.squid_passwd" ]; then
            debug "Found .squid_passwd file"
            PROXY_USER=$(head -n1 /etc/squid/.squid_passwd | cut -d: -f1)
            PROXY_PASS=$(head -n1 /etc/squid/.squid_passwd | cut -d: -f2)
        elif [ -f "/etc/squid/passwd" ]; then
            debug "Found passwd file"
            PROXY_USER=$(head -n1 /etc/squid/passwd | cut -d: -f1)
            PROXY_PASS=$(head -n1 /etc/squid/passwd | cut -d: -f2)
        fi
        
        debug "Found credentials - User: $PROXY_USER, Pass length: ${#PROXY_PASS}"
    fi

    echo "${SERVER_IP}:${PORT}:${PROXY_USER}:${PROXY_PASS}"
}

# Get configuration with debug output
debug "Retrieving proxy configuration..."
CONFIG=$(get_proxy_config)
SERVER_IP=$(echo $CONFIG | cut -d: -f1)
PORT=$(echo $CONFIG | cut -d: -f2)
PROXY_USER=$(echo $CONFIG | cut -d: -f3)
PROXY_PASS=$(echo $CONFIG | cut -d: -f4)

debug "Parsed configuration:"
debug "SERVER_IP: $SERVER_IP"
debug "PORT: $PORT"
debug "PROXY_USER: $PROXY_USER"
debug "PROXY_PASS length: ${#PROXY_PASS}"

if [ ! -z "${PORT}" ] && [ ! -z "${PROXY_USER}" ] && [ ! -z "${PROXY_PASS}" ]; then
    echo -e "\n${CYAN}Proxy Configuration Found:${NC}"
    echo -e "IP: ${GREEN}${SERVER_IP}${NC}"
    echo -e "Port: ${GREEN}${PORT}${NC}"
    echo -e "Username: ${GREEN}${PROXY_USER}${NC}"
    echo -e "Password: ${GREEN}${PROXY_PASS}${NC}"

    # Test local proxy first
    debug "Testing local proxy connection..."
    LOCAL_TEST=$(curl -v -m 5 -x "127.0.0.1:${PORT}" -U "${PROXY_USER}:${PROXY_PASS}" -s https://ip.me 2>&1)
    debug "Local proxy test output: $LOCAL_TEST"

    # Format for proxy6.net test
    PROXY_STRING="${SERVER_IP}:${PORT}:${PROXY_USER}:${PROXY_PASS}"
    debug "Proxy6.net test string: $PROXY_STRING"

    # Test with proxy6.net with verbose output
    echo -e "\n${CYAN}Testing with proxy6.net...${NC}"
    debug "Sending request to proxy6.net..."
    
    RESPONSE=$(curl -v -s -X POST https://proxy6.net/api/check \
        -H "Content-Type: application/json" \
        -d "{\"proxy\":\"${PROXY_STRING}\"}" 2>&1)
    
    debug "Proxy6.net raw response: $RESPONSE"

    if echo "${RESPONSE}" | grep -q "working.*true"; then
        echo -e "${GREEN}Proxy6.net Check Passed ✓${NC}"
        SPEED=$(echo "${RESPONSE}" | grep -o '"response_time":[0-9]*' | cut -d: -f2)
        echo -e "Response Time: ${SPEED}ms"
    else
        echo -e "${RED}Proxy6.net Check Failed ✗${NC}"
        debug "Failed response details: $RESPONSE"
    fi
else
    echo -e "\n${RED}Proxy configuration incomplete:${NC}"
    debug "Missing configuration items:"
    [ -z "$PORT" ] && debug "PORT is missing"
    [ -z "$PROXY_USER" ] && debug "PROXY_USER is missing"
    [ -z "$PROXY_PASS" ] && debug "PROXY_PASS is missing"
fi
