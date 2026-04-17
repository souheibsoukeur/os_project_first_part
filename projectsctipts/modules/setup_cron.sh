#!/bin/bash
# ================================================
# Part 5 - Cron Automation Setup
# Sets up a cron job to run the audit automatically
# ================================================

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIT_SCRIPT="$SCRIPT_DIR/run_audit.sh"
LOG_FILE="$SCRIPT_DIR/reports/cron_log.txt"

# Make sure reports folder exists
mkdir -p "$SCRIPT_DIR/reports"

# ---- Install a cron job ----
install_cron() {
    local schedule="$1"

    # check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "$AUDIT_SCRIPT"; then
        echo "A cron job for this script already exists."
        echo "Removing old one first..."
        crontab -l 2>/dev/null | grep -v "$AUDIT_SCRIPT" | crontab -
    fi

    # add new cron job
    local cron_line="$schedule /bin/bash \"$AUDIT_SCRIPT\" >> \"$LOG_FILE\" 2>&1"
    (crontab -l 2>/dev/null; echo "$cron_line") | crontab -

    echo -e "${GREEN}Cron job installed!${NC}"
    echo -e "  Schedule : ${CYAN}$schedule${NC}"
    echo -e "  Script   : ${CYAN}$AUDIT_SCRIPT${NC}"
    echo -e "  Log      : ${CYAN}$LOG_FILE${NC}"
}

# ---- Remove cron job ----
remove_cron() {
    if crontab -l 2>/dev/null | grep -q "$AUDIT_SCRIPT"; then
        crontab -l 2>/dev/null | grep -v "$AUDIT_SCRIPT" | crontab -
        echo -e "${GREEN}Cron job removed.${NC}"
    else
        echo -e "${YELLOW}No audit cron job found.${NC}"
    fi
}

# ---- Show cron status ----
show_status() {
    echo "-- Current Crontab --"
    crontab -l 2>/dev/null || echo "  (empty)"
    echo ""

    if [ -f "$LOG_FILE" ]; then
        echo "-- Last 10 lines of cron log --"
        tail -10 "$LOG_FILE"
    else
        echo "No cron log found yet."
    fi
}

# ---- Menu ----
echo ""
echo -e "${BOLD}${CYAN}================================${NC}"
echo -e "${BOLD}${CYAN}   Cron Automation - Part 5${NC}"
echo -e "${BOLD}${CYAN}================================${NC}"

# check if audit script exists
if [ ! -f "$AUDIT_SCRIPT" ]; then
    echo "WARNING: $AUDIT_SCRIPT not found!"
fi

while true; do
    echo ""
    echo "  1) Schedule daily at 4:00 AM"
    echo "  2) Schedule every hour"
    echo "  3) Schedule every 6 hours"
    echo "  4) Custom schedule"
    echo "  5) Remove cron job"
    echo "  6) Show cron status"
    echo "  7) Run audit now (test)"
    echo "  0) Exit"
    echo ""
    read -p "Choose an option [0-7]: " choice

    case $choice in
        1) install_cron "0 4 * * *" ;;
        2) install_cron "0 * * * *" ;;
        3) install_cron "0 */6 * * *" ;;
        4)
            echo "Enter cron schedule (example: 30 2 * * 1):"
            read -p "> " custom
            if [ -n "$custom" ]; then
                install_cron "$custom"
            else
                echo "Empty schedule, cancelled."
            fi
            ;;
        5) remove_cron ;;
        6) show_status ;;
        7)
            echo "Running audit now..."
            bash "$AUDIT_SCRIPT"
            echo "Done!"
            ;;
        0) echo "Goodbye!"; break ;;
        *) echo "Invalid option." ;;
    esac
done
