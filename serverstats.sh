#!/bin/bash

# ================================
#    🌐 System Health Monitor
#        Generated: 2025-07-23
# ================================

# ===== Configuration =====
AUTO_UPDATE=true        # Set to false to disable auto updates
FXSERVER_LOG_LINES=40  # Number of FXServer log lines to display

# ===== Color Codes =====
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
BOLD="\033[1m"
UNDERLINE="\033[4m"
RESET="\033[0m"

# ===== Helper Function =====
print_header() {
  echo -e "\n${BOLD}${UNDERLINE}${1}${RESET}"
}

# ===== OS Info =====
print_header "🖥️  OS & Kernel Info"
uname -a
cat /etc/*release | grep PRETTY_NAME || true

# ===== Uptime =====
print_header "⏱️  System Uptime"
uptime -p

# ===== Disk Usage =====
print_header "💽 Disk Usage"
df -hT | grep -v tmpfs

# ===== Memory Usage =====
print_header "🧠 Memory Usage"
free -h

# ===== CPU Load =====
print_header "🧮 CPU Load"
top -bn1 | grep "load average"

# ===== Network Info =====
print_header "🌐 IP Addresses"
hostname -I
ip a | grep inet | grep -v 127.0.0.1

# ===== Firewall Status =====
print_header "🔥 Firewall Status"
if systemctl is-active --quiet firewalld; then
  firewall-cmd --state
  firewall-cmd --list-all || true
elif command -v ufw >/dev/null; then
  ufw status verbose
else
  echo -e "${YELLOW}No active firewall service found (firewalld or ufw).${RESET}"
fi

# ===== Package Updates =====
print_header "📦 Package Updates"
if [ "$AUTO_UPDATE" = true ]; then
  if [ -f /etc/redhat-release ]; then
    dnf check-update || echo -e "${GREEN}No updates available${RESET}"
    dnf upgrade -y
  elif [ -f /etc/debian_version ]; then
    apt update && apt upgrade -y
  else
    echo -e "${YELLOW}Unsupported OS for auto-updates${RESET}"
  fi
else
  echo -e "${YELLOW}Auto-updates are disabled. Skipping...${RESET}"
fi

# ===== Service Statuses =====
print_header "🛠️  Critical Services"
services=("sshd" "nginx" "docker" "mariadb" "postgresql" "firewalld" "fxserver" "fivem-updater")
for svc in "${services[@]}"; do
  if systemctl list-units --type=service --all | grep -q "$svc"; then
    state=$(systemctl is-active "$svc")
    if [[ "$state" == "active" ]]; then
      echo -e "${GREEN}$svc is active${RESET}"
    else
      echo -e "${RED}$svc is $state${RESET}"
    fi
  fi
done

# ===== Last Reboot Time =====
print_header "♻️  Last Reboot"
who -b

# ===== Log Summary: dmesg =====
print_header "🧾 Kernel Log Summary"
dmesg | tail -n 10

# ===== FXServer Logs =====
print_header "📝 FXServer Logs (Last $FXSERVER_LOG_LINES lines)"
FXSERVER_LOG_PATHS=(
  "/root/FXServer/server/txData/default/logs/fxserver.log"
  "/home/fxserver/txData/default/logs/fxserver.log"
  "/opt/fivem/txData/default/logs/fxserver.log"
  "/var/lib/fivem/txData/default/logs/fxserver.log"
)

found_log=false
for log_path in "${FXSERVER_LOG_PATHS[@]}"; do
  if [[ -f "$log_path" ]]; then
    tail -n "$FXSERVER_LOG_LINES" "$log_path" | awk '
      /error/i { print "\033[31m" $0 "\033[0m"; next }
      /warn/i { print "\033[33m" $0 "\033[0m"; next }
      /started|listening|success|ready/i { print "\033[32m" $0 "\033[0m"; next }
      { print $0 }
    '
    found_log=true
    break
  fi
done

if ! $found_log; then
  echo -e "${RED}No FXServer log found in expected locations.${RESET}"
fi

# ===== End =====
echo -e "\n${CYAN}✅ Health check complete.${RESET}"

