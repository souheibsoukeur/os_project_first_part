# os_project_first_part
this project is done by souheib soukeur and moulai mostefa mohamed adnane

# Linux System Audit Tool

## Description

This project is an automated Linux system audit tool built with Bash shell scripting. It collects hardware and software information from the system, generates formatted reports, and supports automated execution via cron jobs and remote monitoring via SSH.

## Project Structure

```
projectsctipts/
├── main.sh                    # Main entry point (run this)
├── README.md                  # This file
├── modules/
    ├── firstpart.sh           # Part 1 - Hardware Audit
    ├── software_audit.sh      # Part 2 - OS & Software Audit
    ├── report_generator.sh    # Part 3 - Report Generator
    ├── send_email.sh          # Part 4 - Email Report Sender
    ├── run_audit.sh           # Full audit pipeline
    ├── setup_cron.sh          # Part 5 - Cron Automation
    └── remote_monitor.sh      # Part 6 - Remote Monitoring (SSH)
    |--reports/                # Generated reports are saved here
```

## How to Run

### 1. Make the scripts executable

```bash
chmod +x main.sh
chmod +x modules/*.sh
```

### 2. Run the main script

```bash
bash main.sh
```

This will show a menu with the following options:

- **1)** Run Hardware Audit (CPU, RAM, Disk, GPU, Network, etc.)
- **2)** Run Software Audit (OS, Kernel, Packages, Users, Services, etc.)
- **3)** Generate Reports (Short TXT, Short JSON, Full TXT)
- **4)** Send Report by Email
- **5)** Setup Cron Job (schedule automatic audits)
- **6)** Remote Monitoring (audit remote machines via SSH)
- **7)** Run Full Audit (runs everything and generates all reports)

### 3. Run individual modules

```bash
bash modules/hardware_audit.sh   # Hardware audit
bash modules/software_audit.sh   # Software audit
bash modules/report_generator.sh # Report generator
bash modules/send_email.sh       # Email sender
bash modules/run_audit.sh        # Full audit
bash modules/setup_cron.sh       # Cron setup
bash modules/remote_monitor.sh   # Remote monitoring
```

## Reports

Reports are saved in the `modules/reports` folder:

- **Short Report (TXT)** - Quick summary with key system info
- **Short Report (JSON)** - Same summary in JSON format
- **Full Report (TXT)** - Complete detailed audit

Each report includes date/time stamp, hostname, and full hardware + software details.

## Email (Part 4)

Send reports by email using `mail`, `msmtp`, or `sendmail`. Configure your email tool first:

```bash
sudo apt install msmtp msmtp-mta
```

## Automation (Part 5)

Schedule automatic audits with cron. Available schedules: daily at 4:00 AM, hourly, every 6 hours, or custom.

## Remote Monitoring (Part 6)

Monitor remote machines via SSH:
- Run audit commands on a remote machine
- Send reports to a remote server using SCP
- Live monitoring (uptime, RAM, disk) every 10 seconds

## Requirements

- Linux OS (tested on Kali Linux)
- Bash shell
- Standard Linux tools: `lsblk`, `lspci`, `lsusb`, `free`, `df`, `ss`, `systemctl`
- SSH/SCP (for remote monitoring)

## Authors

souheib soukeur / moulai mostefa mohamed adnane - NSCS 2025/2026
