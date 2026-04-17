#!/bin/bash
# ================================================
# Part 6 - Remote Monitoring via SSH
# Run audit on a remote machine or send reports
# to a remote server using SSH/SCP
# ================================================

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="$SCRIPT_DIR/reports"

# ---- Run audit on remote machine ----
remote_audit() {
    local remote_host="$1"
    local remote_user="$2"

    echo -e "${YELLOW}Connecting to $remote_user@$remote_host via SSH...${NC}"
    echo ""

    # run basic audit commands on the remote machine
    ssh "$remote_user@$remote_host" bash -s <<'REMOTE_COMMANDS'
echo "===== Remote System Audit ====="
echo ""
echo "Hostname : $(hostname)"
echo "Date     : $(date)"
echo "OS       : $(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d= -f2)"
echo "Kernel   : $(uname -r)"
echo "Arch     : $(uname -m)"
echo "CPU      : $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2)"
echo "RAM      : $(free -h | grep Mem | awk '{print $2}')"
echo "Disk     : $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"
echo "Uptime   : $(uptime -p)"
echo "Users    : $(who | wc -l) logged in"
echo ""
echo "===== End of Remote Audit ====="
REMOTE_COMMANDS

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}Remote audit completed!${NC}"
    else
        echo -e "${RED}SSH connection failed!${NC}"
    fi
}

# ---- Send report to remote server ----
send_report_remote() {
    local remote_host="$1"
    local remote_user="$2"
    local report_file="$3"
    local remote_path="$4"

    if [ ! -f "$report_file" ]; then
        echo -e "${RED}Report file not found: $report_file${NC}"
        return 1
    fi

    echo -e "${YELLOW}Sending report to $remote_user@$remote_host:$remote_path ...${NC}"
    scp "$report_file" "$remote_user@$remote_host:$remote_path"

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Report sent successfully!${NC}"
    else
        echo -e "${RED}Failed to send report!${NC}"
    fi
}

# ---- Monitor remote machine ----
monitor_remote() {
    local remote_host="$1"
    local remote_user="$2"

    echo -e "${YELLOW}Monitoring $remote_user@$remote_host (press Ctrl+C to stop)...${NC}"
    echo ""

    while true; do
        echo -e "${CYAN}--- $(date) ---${NC}"
        ssh "$remote_user@$remote_host" "uptime; echo ''; free -h | head -2; echo ''; df -h / | tail -1" 2>/dev/null

        if [ $? -ne 0 ]; then
            echo -e "${RED}Connection lost!${NC}"
            break
        fi

        echo ""
        sleep 10
    done
}

# ---- Menu ----
echo ""
echo -e "${BOLD}${CYAN}======================================${NC}"
echo -e "${BOLD}${CYAN}   Remote Monitoring - Part 6${NC}"
echo -e "${BOLD}${CYAN}======================================${NC}"

while true; do
    echo ""
    echo "  1) Run audit on remote machine"
    echo "  2) Send report to remote server"
    echo "  3) Monitor remote machine (live)"
    echo "  0) Exit"
    echo ""
    read -p "Choose an option [0-3]: " choice

    case $choice in
        1)
            read -p "Remote host (IP or hostname): " host
            read -p "Remote username: " user
            remote_audit "$host" "$user"
            ;;
        2)
            read -p "Remote host (IP or hostname): " host
            read -p "Remote username: " user
            read -p "Report filename (from reports/): " filename
            read -p "Remote destination path (e.g. /tmp/): " dest
            send_report_remote "$host" "$user" "$REPORT_DIR/$filename" "$dest"
            ;;
        3)
            read -p "Remote host (IP or hostname): " host
            read -p "Remote username: " user
            monitor_remote "$host" "$user"
            ;;
        0)
            echo -e "${GREEN}Goodbye!${NC}"
            break
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
done
