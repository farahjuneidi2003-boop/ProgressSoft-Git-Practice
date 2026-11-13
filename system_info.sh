#!/bin/bash

echo "System Information"
echo "------------------"
echo "Executed By: $(whoami)"
echo "Hostname: $(hostname)"
echo "Server IP: $(hostname -I | awk '{print $1}')"
echo "Public IP: $(curl -s https://api.ipify.org)"
echo "OS Type and Version: $(. /etc/os-release && echo "$PRETTY_NAME")"
echo "Kernel Version: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Virtualization: $(systemd-detect-virt)"
echo "Server Time: $(date)"
echo "Timezone: $(timedatectl show -p Timezone --value)"
echo "Uptime: $(uptime -p)"

echo
echo "Resource Usage"
echo "--------------"
echo "Total Memory: $(free -h | awk '/Mem:/ {print $2}')"
echo "Memory Usage: $(free -h | awk '/Mem:/ {print $3 " / " $2}')"
echo "Swap Usage: $(free -h | awk '/Swap:/ {print $3 " / " $2}')"
echo "CPU Cores: $(nproc)"
