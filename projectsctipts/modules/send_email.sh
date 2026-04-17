#!/bin/bash
# ================================================
# Part 4 - Email Report Sender
# Sends a generated report to an email address
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

# ---- Send email ----
send_email() {
    local recipient="$1"
    local report_file="$2"
    local subject="System Audit Report - $(hostname) - $(date '+%Y-%m-%d')"

    # check if report file exists
    if [ ! -f "$report_file" ]; then
        echo -e "${RED}Error: Report file not found: $report_file${NC}"
        return 1
    fi

    # try to send with mail command
    if command -v mail > /dev/null; then
        mail -s "$subject" "$recipient" < "$report_file"
        echo -e "${GREEN}Email sent to $recipient using 'mail'${NC}"

    elif command -v msmtp > /dev/null; then
        # send using msmtp
        {
            echo "Subject: $subject"
            echo "To: $recipient"
            echo ""
            cat "$report_file"
        } | msmtp "$recipient"
        echo -e "${GREEN}Email sent to $recipient using 'msmtp'${NC}"

    elif command -v sendmail > /dev/null; then
        {
            echo "Subject: $subject"
            echo "To: $recipient"
            echo ""
            cat "$report_file"
        } | sendmail "$recipient"
        echo -e "${GREEN}Email sent to $recipient using 'sendmail'${NC}"

    else
        echo -e "${RED}No email tool found!${NC}"
        echo "Install one of: mailutils, msmtp, or sendmail"
        echo ""
        echo "To install msmtp (easiest):"
        echo "  sudo apt install msmtp msmtp-mta"
        echo ""
        echo "Then configure ~/.msmtprc with your email settings."
        return 1
    fi
}

# ---- List available reports ----
list_reports() {
    echo ""
    echo -e "${BOLD}Available reports:${NC}"
    local i=1
    for f in "$REPORT_DIR"/*.txt "$REPORT_DIR"/*.json; do
        if [ -f "$f" ]; then
            echo "  $i) $(basename "$f")"
            i=$((i + 1))
        fi
    done
    echo ""
}

# ---- Menu ----
echo ""
echo -e "${BOLD}${CYAN}================================${NC}"
echo -e "${BOLD}${CYAN}   Email Report Sender - Part 4${NC}"
echo -e "${BOLD}${CYAN}================================${NC}"

while true; do
    echo ""
    echo "  1) Send a report by email"
    echo "  2) List available reports"
    echo "  0) Exit"
    echo ""
    read -p "Choose an option [0-2]: " choice

    case $choice in
        1)
            # Ask for email
            read -p "Enter recipient email: " email
            if [ -z "$email" ]; then
                echo -e "${RED}Empty email, cancelled.${NC}"
                continue
            fi

            # Show reports and ask which one
            list_reports
            read -p "Enter report filename: " filename
            report_path="$REPORT_DIR/$filename"

            send_email "$email" "$report_path"
            ;;
        2)
            list_reports
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
