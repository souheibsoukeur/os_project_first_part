#!/bin/bash
# ================================================
# Part 3 - Report Generator
# Generates short and full reports in TXT and JSON
# ================================================

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'
MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the audit modules
source "$MODULE_DIR/software_audit.sh"

if [ -f "$MODULE_DIR/hardware_audit.sh" ]; then
    source "$MODULE_DIR/hardware_audit.sh"
fi

# Reports folder
REPORT_DIR="${REPORT_DIR:-$MODULE_DIR/reports}"
mkdir -p "$REPORT_DIR"

# ---- Short Report (TXT) ----
generate_short_txt() {
    local file="$REPORT_DIR/short_report_$(date +%Y%m%d_%H%M%S).md"

    {
        echo "========================================"
        echo "   SYSTEM AUDIT - SHORT REPORT"
        echo "========================================"
        echo "Date     : $(date)"
        echo "Hostname : $(hostname)"
        echo "User     : $(whoami)"
        echo "----------------------------------------"
        echo ""
        echo "--- Hardware Summary ---"
        echo "CPU     : $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2)"
        echo "Cores   : $(nproc)"
        echo "RAM     : $(free -h | grep Mem | awk '{print $2}')"
        echo ""
        echo "--- Software Summary ---"
        if [ -f /etc/os-release ]; then
            source /etc/os-release
            echo "OS      : $PRETTY_NAME"
        fi
        echo "Kernel  : $(uname -r)"
        echo "Arch    : $(uname -m)"
        echo "Packages: $(dpkg -l 2>/dev/null | grep '^ii' | wc -l) installed"
        echo "Users   : $(who | wc -l) logged in"
        echo ""
        echo "========================================"
        echo "   END OF SHORT REPORT"
        echo "========================================"
    } > "$file"

    echo -e "${GREEN}[OK]${NC} Short TXT report saved: ${CYAN}$file${NC}"
}

# ---- Short Report (JSON) ----
generate_short_json() {
    local file="$REPORT_DIR/short_report_$(date +%Y%m%d_%H%M%S).json"

    # Get OS name
    os_name="Unknown"
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        os_name="$PRETTY_NAME"
    fi

    cat > "$file" <<EOF
{
    "report_type": "short",
    "date": "$(date)",
    "hostname": "$(hostname)",
    "os": "$os_name",
    "kernel": "$(uname -r)",
    "architecture": "$(uname -m)",
    "cpu_cores": $(nproc),
    "installed_packages": $(dpkg -l 2>/dev/null | grep '^ii' | wc -l),
    "logged_in_users": $(who | wc -l)
}
EOF

    echo -e "${GREEN}[OK]${NC} Short JSON report saved: ${CYAN}$file${NC}"
}

# ---- Full Report (TXT) ----
generate_full_txt() {
    local file="$REPORT_DIR/full_report_$(date +%Y%m%d_%H%M%S).md"

    {
        echo "========================================"
        echo "   SYSTEM AUDIT - FULL REPORT"
        echo "========================================"
        echo "Date     : $(date)"
        echo "Hostname : $(hostname)"
        echo "User     : $(whoami)"
        echo "========================================"

        echo ""
        echo "###########################"
        echo "#  PART 1: HARDWARE AUDIT #"
        echo "###########################"
        echo ""
        run_hardware_audit

        echo ""
        echo "###########################"
        echo "#  PART 2: SOFTWARE AUDIT #"
        echo "###########################"
        echo ""
        run_software_audit

        echo ""
        echo "========================================"
        echo "   END OF FULL REPORT"
        echo "========================================"
    } > "$file"

    echo -e "${GREEN}[OK]${NC} Full TXT report saved: ${CYAN}$file${NC}"
}

# ---- Generate all reports ----
generate_all_reports() {
    echo -e "${YELLOW}Generating all reports...${NC}"
    generate_short_txt
    generate_short_json
    generate_full_txt
    echo -e "${GREEN}Done!${NC} All reports saved in: ${CYAN}$REPORT_DIR${NC}"
}

# ---- Simple Menu ----
show_menu() {
    echo ""
    echo -e "${BOLD}${CYAN}================================${NC}"
    echo -e "${BOLD}${CYAN}   Report Generator - Part 3${NC}"
    echo -e "${BOLD}${CYAN}================================${NC}"
    echo "  1) Short Report (TXT)"
    echo "  2) Short Report (JSON)"
    echo "  3) Full Report  (TXT)"
    echo "  4) All Reports"
    echo "  0) Exit"
    echo "================================"
    echo ""
}

# ---- Main loop ----
run_report_menu() {
    while true; do
        show_menu
        read -p "Choose an option [0-4]: " choice

        case $choice in
            1) generate_short_txt ;;
            2) generate_short_json ;;
            3) generate_full_txt ;;
            4) generate_all_reports ;;
            0) echo "Goodbye!"; break ;;
            *) echo "Invalid option, try again." ;;
        esac
    done
}

# Run directly if not sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    run_report_menu
fi
