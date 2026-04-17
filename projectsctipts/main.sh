#!/bin/bash
# ================================================
# main.sh - Main Menu for Linux System Audit
# This is the main entry point for the project.
# It lets the user choose what to do from a menu.
# ================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add sbin to PATH for cron/admin tools
export PATH=$PATH:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin

# Source all modules
source "$SCRIPT_DIR/modules/hardware_audit.sh"
source "$SCRIPT_DIR/modules/software_audit.sh"
source "$SCRIPT_DIR/modules/report_generator.sh"

# ---- Main Menu ----
show_main_menu() {
    echo ""
    echo -e "${BOLD}${CYAN}========================================${NC}"
    echo -e "${BOLD}${CYAN}     Linux System Audit Tool${NC}"
    echo -e "${BOLD}${CYAN}========================================${NC}"
    echo ""
    echo "  1) Run Hardware Audit  (Part 1)"
    echo "  2) Run Software Audit  (Part 2)"
    echo "  3) Generate Reports    (Part 3)"
    echo "  4) Send Report by Email(Part 4)"
    echo "  5) Setup Cron Job      (Part 5)"
    echo "  6) Remote Monitoring   (Part 6)"
    echo "  7) Run Full Audit      (All Parts)"
    echo "  0) Exit"
    echo ""
    echo -e "${BOLD}${CYAN}========================================${NC}"
    echo ""
}

# ---- Main Loop ----
while true; do
    show_main_menu
    read -p "Choose an option [0-7]: " choice

    case $choice in
        1)
            echo ""
            echo -e "${YELLOW}Running Hardware Audit...${NC}"
            echo ""
            run_hardware_audit
            ;;
        2)
            echo ""
            echo -e "${YELLOW}Running Software Audit...${NC}"
            echo ""
            run_software_audit
            ;;
        3)
            echo ""
            run_report_menu
            ;;
        4)
            echo ""
            bash "$SCRIPT_DIR/modules/send_email.sh"
            ;;
        5)
            echo ""
            bash "$SCRIPT_DIR/modules/setup_cron.sh"
            ;;
        6)
            echo ""
            bash "$SCRIPT_DIR/modules/remote_monitor.sh"
            ;;
        7)
            echo ""
            echo -e "${YELLOW}Running Full Audit...${NC}"
            bash "$SCRIPT_DIR/modules/run_audit.sh"
            ;;
        0)
            echo -e "${GREEN}Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option, try again.${NC}"
            ;;
    esac
done
