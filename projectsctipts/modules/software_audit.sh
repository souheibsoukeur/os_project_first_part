#!/bin/bash
# ================================================
# Part 2 - OS & Software Audit
# Collects OS info, packages, users, services, etc.
# ================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

# Function to print a section title
print_title() {
    echo ""
    echo -e "${BOLD}${CYAN}===== $1 =====${NC}"
    echo ""
}

# ---- OS Information ----
get_os_info() {
    print_title "OS Information"

    # read from /etc/os-release
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo -e "  OS Name    : ${GREEN}$NAME${NC}"
        echo -e "  OS Version : ${GREEN}$VERSION_ID${NC}"
        echo -e "  Full Name  : ${GREEN}$PRETTY_NAME${NC}"
    else
        echo "  OS : $(uname -s)"
    fi
}

# ---- Kernel Information ----
get_kernel_info() {
    print_title "Kernel"
    echo -e "  Kernel Version : ${GREEN}$(uname -r)${NC}"
}

# ---- Architecture ----
get_arch_info() {
    print_title "System Info"
    echo -e "  Architecture : ${GREEN}$(uname -m)${NC}"
    echo -e "  Hostname     : ${GREEN}$(hostname)${NC}"
    echo -e "  Date/Time    : ${GREEN}$(date)${NC}"
}

# ---- Installed Packages ----
get_packages_info() {
    print_title "Installed Packages"

    if command -v dpkg > /dev/null; then
        total=$(dpkg -l | grep "^ii" | wc -l)
        echo -e "  Package Manager : ${GREEN}dpkg/apt${NC}"
        echo -e "  Total Packages  : ${GREEN}$total${NC}"
        echo ""
        echo "  (showing first 20 packages)"
        dpkg -l | grep "^ii" | head -20 | awk '{print "  " $2 " - " $3}'
    elif command -v rpm > /dev/null; then
        total=$(rpm -qa | wc -l)
        echo "  Package Manager : rpm"
        echo "  Total Packages  : $total"
    else
        echo "  No supported package manager found"
    fi
}

# ---- Users ----
get_users_info() {
    print_title "Users"

    echo "  -- Currently Logged-in --"
    who
    echo ""
    echo "  -- Users with Login Shell --"
    grep -E "/bin/bash|/bin/sh|/bin/zsh" /etc/passwd | cut -d ':' -f1
}

# ---- Running Services ----
get_services_processes() {
    print_title "Running Services & Processes"

    echo "  -- Running Services --"
    if command -v systemctl > /dev/null; then
        systemctl list-units --type=service --state=running --no-pager 2>/dev/null | head -20
    else
        echo "  systemctl not available"
    fi
    echo ""

    echo "  -- Top 10 Processes (by CPU) --"
    ps aux --sort=-%cpu | head -11
}

# ---- Open Ports ----
get_open_ports() {
    print_title "Open Ports"

    if command -v ss > /dev/null; then
        ss -tulnp 2>/dev/null
    elif command -v netstat > /dev/null; then
        netstat -tulnp 2>/dev/null
    else
        echo "  No tool found for listing ports"
    fi
}

# ---- Extra Info ----
get_extra_info() {
    print_title "Extra Information"

    # Uptime
    echo "  -- Uptime --"
    uptime
    echo ""

    # Environment
    echo "  -- Environment --"
    echo -e "  SHELL : ${GREEN}$SHELL${NC}"
    echo -e "  USER  : ${GREEN}$USER${NC}"
    echo -e "  HOME  : ${GREEN}$HOME${NC}"
    echo ""

    # Cron jobs
    echo "  -- Cron Jobs --"
    crontab -l 2>/dev/null || echo "  No cron jobs for current user"
}

# ---- Run all software audits ----
run_software_audit() {
    get_os_info
    get_kernel_info
    get_arch_info
    get_packages_info
    get_users_info
    get_services_processes
    get_open_ports
    get_extra_info
}

# Run directly if not sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo -e "${BOLD}${CYAN}===============================${NC}"
    echo -e "${BOLD}${CYAN}   OS & Software Audit - Part 2${NC}"
    echo -e "${BOLD}${CYAN}===============================${NC}"
    run_software_audit
fi
