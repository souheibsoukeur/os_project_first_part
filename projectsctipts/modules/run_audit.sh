#!/bin/bash
# ================================================
# run_audit.sh - Main Audit Script
# Runs all parts: hardware audit, software audit,
# then generates reports.
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
REPORT_DIR="$SCRIPT_DIR/reports"
LOG_FILE="$REPORT_DIR/audit_log.txt"

# Add sbin to PATH for cron/admin tools
export PATH=$PATH:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin

# Create reports folder
mkdir -p "$REPORT_DIR"

# Function to write to log file
log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

echo ""
echo -e "${BOLD}${CYAN}========================================${NC}"
echo -e "${BOLD}${CYAN}   Linux System Audit${NC}"
echo -e "${BOLD}${CYAN}========================================${NC}"
echo ""

log_msg "Audit started by $(whoami)"

# ---- Step 1: Load modules ----
echo -e "${CYAN}[1/3]${NC} Loading modules..."

# Load hardware audit (Part 1)
if [ -f "$SCRIPT_DIR/hardware_audit.sh" ]; then
    source "$SCRIPT_DIR/hardware_audit.sh"
    log_msg "hardware_audit.sh loaded"
    echo -e "  -> ${GREEN}Hardware module loaded${NC}"
else
    echo -e "  -> ${YELLOW}WARNING: hardware_audit.sh not found${NC}"
    log_msg "hardware_audit.sh not found"
fi

# Load software audit (Part 2)
if [ -f "$SCRIPT_DIR/software_audit.sh" ]; then
    source "$SCRIPT_DIR/software_audit.sh"
    log_msg "software_audit.sh loaded"
    echo -e "  -> ${GREEN}Software module loaded${NC}"
else
    echo -e "  -> ${RED}ERROR: software_audit.sh not found!${NC}"
    log_msg "ERROR: software_audit.sh not found"
    exit 1
fi

# Load report generator (Part 3)
if [ -f "$SCRIPT_DIR/report_generator.sh" ]; then
    source "$SCRIPT_DIR/report_generator.sh"
    log_msg "report_generator.sh loaded"
    echo -e "  -> ${GREEN}Report generator loaded${NC}"
else
    echo -e "  -> ${RED}ERROR: report_generator.sh not found!${NC}"
    log_msg "ERROR: report_generator.sh not found"
    exit 1
fi

echo ""

# ---- Step 2: Run audits ----
echo -e "${CYAN}[2/3]${NC} Running audits..."

# Run hardware audit and save to file
echo -e "  -> Running hardware audit..."
run_hardware_audit > "$REPORT_DIR/hardware_raw.txt" 2>&1
log_msg "Hardware audit done"

# Run software audit and save to file
echo -e "  -> Running software audit..."
run_software_audit > "$REPORT_DIR/software_raw.txt" 2>&1
log_msg "Software audit done"

echo ""

# ---- Step 3: Generate reports ----
echo -e "${CYAN}[3/3]${NC} Generating reports..."
export REPORT_DIR
generate_all_reports
log_msg "Reports generated"

# ---- Summary ----
echo ""
echo -e "${BOLD}${CYAN}========================================${NC}"
echo -e "${BOLD}${CYAN}   Audit Complete!${NC}"
echo -e "${BOLD}${CYAN}========================================${NC}"
echo -e "  Hostname : ${GREEN}$(hostname)${NC}"
echo -e "  Date     : ${GREEN}$(date)${NC}"
echo -e "  Reports  : ${GREEN}$REPORT_DIR${NC}"
echo ""
echo "  Files created:"
ls -1 "$REPORT_DIR" | while read f; do
    echo "    + $f"
done
echo "========================================"

log_msg "Audit finished"
