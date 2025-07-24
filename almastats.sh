#!/bin/bash

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
BLUE="\e[34m"
NC="\e[0m" # No Color

echo -e "${YELLOW}===== SERVER HEALTH OVERVIEW =====${NC}"

# OS & Kernel
echo -e "${CYAN}OS & Kernel:${NC}"
uname -a
cat /etc/os-release | grep PRETTY_NAME
echo

# Uptime, Load, Users
echo -e "${CYAN}Uptime / Load / Users:${NC}"
uptime
echo

# CPU / Mem / Swap
echo -e "${CYAN}CPU / Memory / Swap:${NC}"
free -h
echo

# Disk Usage
echo -e "${CYAN}Disk Usage:${NC}"
df -h --output=source,size,used,avail,pcent,target | column -t
echo

# Top Processes (optional)
echo -e "${CYAN}Top Resource-Consuming Processes:${NC}"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 10
echo

# Network Info
echo -e "${CYAN}IP Address / Interfaces:${NC}"
ip a | grep -v "inet6" | grep inet
echo

echo -e "${CYAN}Open Ports:${NC}"
ss -tuln | grep LISTEN
echo

# Firewall Detection
echo -e "${CYAN}Firewall Status:${NC}"
if command -v firewall-cmd &>/dev/null; then
    echo -e "${YELLOW}Firewalld:${NC}"
    firewall-cmd --state
    firewall-cmd --list-all
elif command -v ufw &>/dev/null; then
    echo -e "${YELLOW}UFW:${NC}"
    ufw status verbose
else
    echo -e "${RED}No firewall tool (firewalld or ufw) detected.${NC}"
fi
echo

# Service Status Summary
echo -e "${CYAN}Important Service Statuses:${NC}"
services=("firewalld" "nginx" "httpd" "docker" "mariadb" "postgresql" "sshd" "fxserver" "fivem-updater")
for svc in "${services[@]}"; do
  if systemctl list-unit-files | grep -q "^$svc.service"; then
    STATUS=$(systemctl is-active "$svc")
    COLOR=$([[ "$STATUS" == "active" ]] && echo "$GREEN" || echo "$RED")
    echo -e "$svc: ${COLOR}$STATUS${NC}"
  fi
done
echo

# Last 30 Journalctl Log Errors (non-fxserver)
echo -e "${CYAN}Recent System Errors (journalctl):${NC}"
journalctl -p 3 -xb -n 30 --no-pager 2>/dev/null || echo -e "${RED}No errors or journalctl not supported.${NC}"
echo

# === FXSERVER LOGS ===
echo -e "${YELLOW}--- FXServer Logs (last 40 lines, TXAdmin-style colors) ---${NC}"

color_logs() {
  while IFS= read -r line; do
    if [[ "$line" == *"[txAdmin]"* ]]; then
      echo -e "${BLUE}$line${NC}"
    elif [[ "$line" == *"[ERROR]"* || "$line" == *"[Error]"* ]]; then
      echo -e "${RED}$line${NC}"
    elif [[ "$line" == *"[WARNING]"* || "$line" == *"[Warning]"* ]]; then
      echo -e "${YELLOW}$line${NC}"
    elif [[ "$line" == *"[INFO]"* || "$line" == *"[Info]"* ]]; then
      echo -e "${GREEN}$line${NC}"
    elif [[ "$line" == *"[DEBUG]"* || "$line" == *"[Debug]"* ]]; then
      echo -e "${CYAN}$line${NC}"
    else
      echo "$line"
    fi
  done
}

# Attempt to find fxserver logs
if journalctl -u fxserver.service &>/dev/null; then
  journalctl -u fxserver.service -n 40 --no-pager | color_logs
elif [ -f "/home/fxuser/fxserver-data/logs/latest.log" ]; then
  tail -n 40 /home/fxuser/fxserver-data/logs/latest.log | color_logs
elif screen -ls | grep -q fxserver; then
  screen -S fxserver -X hardcopy /tmp/fx_log.out && tail -n 40 /tmp/fx_log.out | color_logs
else
  echo -e "${RED}No FXServer logs found or service not running.${NC}"
fi

