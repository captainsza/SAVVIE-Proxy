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

if cat /etc/os-release | grep PRETTY_NAME | grep "Ubuntu 22.04" > /dev/null; then
    echo "ubuntu2204"
elif cat /etc/os-release | grep PRETTY_NAME | grep "Ubuntu 20.04" > /dev/null; then
    echo "ubuntu2004"
elif cat /etc/os-release | grep PRETTY_NAME | grep "Ubuntu 18.04" > /dev/null; then
    echo "ubuntu1804"
elif cat /etc/os-release | grep PRETTY_NAME | grep "Ubuntu 16.04" > /dev/null; then
    echo "ubuntu1604"
elif cat /etc/*release | grep DISTRIB_DESCRIPTION | grep "Ubuntu 14.04" > /dev/null; then
    echo "ubuntu1404"
elif cat /etc/os-release | grep PRETTY_NAME | grep "jessie" > /dev/null; then
    echo "debian8"
elif cat /etc/os-release | grep PRETTY_NAME | grep "stretch" > /dev/null; then
    echo "debian9"
elif cat /etc/os-release | grep PRETTY_NAME | grep "buster" > /dev/null; then
    echo "debian10"
elif cat /etc/os-release | grep PRETTY_NAME | grep "bullseye" > /dev/null; then
    echo "debian11"
elif cat /etc/os-release | grep PRETTY_NAME | grep "bookworm" > /dev/null; then
    echo "debian12"
elif cat /etc/os-release | grep PRETTY_NAME | grep "CentOS Linux 7" > /dev/null; then
    echo "centos7"
elif cat /etc/os-release | grep PRETTY_NAME | grep "CentOS Linux 8" > /dev/null; then
    echo "centos8"
elif cat /etc/os-release | grep PRETTY_NAME | grep "AlmaLinux 8" > /dev/null; then
    echo "almalinux8"
elif cat /etc/os-release | grep PRETTY_NAME | grep "AlmaLinux 8" > /dev/null; then
    echo "almalinux9"
elif cat /etc/os-release | grep PRETTY_NAME | grep "CentOS Stream 8" > /dev/null; then
    echo "centos8s"
elif cat /etc/os-release | grep PRETTY_NAME | grep "CentOS Stream 9" > /dev/null; then
    echo "centos9"
else
    echo "ERROR"
fi
