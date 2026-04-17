#!/bin/bash
# ================================================
# Part 1 - Hardware Audit
# Collects hardware info: CPU, RAM, Disk, GPU, etc.
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

# ---- CPU Information ----
audit_cpu() {
    print_title "CPU Information"

    # get CPU model
    cpu_model=$(grep -m1 "model name" /proc/cpuinfo | cut -d ':' -f2)
    echo -e "  Model      :${GREEN}$cpu_model${NC}"

    # architecture
    echo -e "  Architecture: ${GREEN}$(uname -m)${NC}"

    # number of cores
    cores=$(nproc)
    echo -e "  CPU Cores  : ${GREEN}$cores${NC}"

    # cpu frequency
    freq=$(grep -m1 "cpu MHz" /proc/cpuinfo | cut -d ':' -f2)
    echo -e "  Frequency  :${GREEN}$freq MHz${NC}"
}

# ---- Memory Information ----
audit_memory() {
    print_title "Memory (RAM)"

    # show memory info using free command
    free -h
    echo ""

    # show swap info
    echo "  Swap Info:"
    swapon --show 2>/dev/null || echo "  No swap configured"
}

# ---- Disk Information ----
audit_disk() {
    print_title "Disk Information"

    # show disk partitions
    echo "  -- Block Devices --"
    lsblk
    echo ""

    # show disk usage
    echo "  -- Disk Usage --"
    df -h
}

# ---- GPU Information ----
audit_gpu() {
    print_title "GPU Information"

    # use lspci to find GPU
    if command -v lspci > /dev/null; then
        lspci | grep -i "vga\|3d\|display"
    else
        echo "  lspci not installed, cannot detect GPU"
    fi
}

# ---- Network Interfaces ----
audit_network() {
    print_title "Network Interfaces"

    # show network interfaces and IPs
    if command -v ip > /dev/null; then
        ip addr show
    else
        ifconfig
    fi
}

# ---- MAC Addresses ----
audit_mac() {
    print_title "MAC Addresses"

    # read MAC address from /sys for each interface
    for iface in /sys/class/net/*; do
        name=$(basename "$iface")
        mac=$(cat "$iface/address" 2>/dev/null)
        echo -e "  $name : ${GREEN}$mac${NC}"
    done
}

# ---- Motherboard Info ----
audit_motherboard() {
    print_title "Motherboard Information"

    # try to read from /sys/class/dmi/id
    if [ -d /sys/class/dmi/id ]; then
        echo -e "  Board Vendor : ${GREEN}$(cat /sys/class/dmi/id/board_vendor 2>/dev/null)${NC}"
        echo -e "  Board Name   : ${GREEN}$(cat /sys/class/dmi/id/board_name 2>/dev/null)${NC}"
        echo -e "  BIOS Vendor  : ${GREEN}$(cat /sys/class/dmi/id/bios_vendor 2>/dev/null)${NC}"
        echo -e "  BIOS Version : ${GREEN}$(cat /sys/class/dmi/id/bios_version 2>/dev/null)${NC}"
    else
        echo "  Cannot read motherboard info (need root)"
    fi
}

# ---- USB Devices ----
audit_usb() {
    print_title "USB Devices"

    if command -v lsusb > /dev/null; then
        lsusb
    else
        echo "  lsusb not installed"
    fi
}

# ---- Run all hardware audits ----
run_hardware_audit() {
    audit_cpu
    audit_memory
    audit_disk
    audit_gpu
    audit_network
    audit_mac
    audit_motherboard
    audit_usb
}

# Run directly if not sourced
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    echo -e "${BOLD}${CYAN}===============================${NC}"
    echo -e "${BOLD}${CYAN}   Hardware Audit - Part 1${NC}"
    echo -e "${BOLD}${CYAN}===============================${NC}"
    run_hardware_audit
fi
