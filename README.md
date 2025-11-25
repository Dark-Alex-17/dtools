# Devtools

![Release](https://img.shields.io/github/v/release/Dark-Alex-17/dtools?color=%23c694ff)
[![GitHub Downloads](https://img.shields.io/github/downloads/Dark-Alex-17/dtools/total.svg?label=GitHub%20downloads)](https://github.com/Dark-Alex-17/dtools/releases)

**Devtools (`dtools`)** is a comprehensive CLI utility that consolidates reusable development scripts, tools, and 
references into a single, easy-to-use interface. Built with the [Bashly](https://github.com/DannyBen/bashly) framework, it serves multiple purposes:

- **Script Repository**: A centralized collection of battle-tested bash scripts for common development tasks
- **Functional Documentation**: Reference implementations showing how to interact with various tools and services
- **Quick Reference**: Documentation commands (like `tui` and `pentest` subcommands) that list useful tools and commands 
  you might not use daily

Whether you need to spin up a local database, manage AWS resources, analyze code, or just remember that one command you 
always forget, `dtools` has you covered.

---
## Warnings
* **I've only tested these scripts against Debian-based systems (Ubuntu, Pop!_OS, etc.). Some scripts may not
  work on other systems.**
* **Some scripts assume that `bash` is your default shell, and thus assume that your shell configuration files are
  `.bashrc`. If you use another shell, you may need to modify some scripts to fit your environment.**

For any and all issues, don't hesitate to create a bug report or feature request on the [GitHub Issues page](https://github.com/Dark-Alex-17/dtools/issues)!
---

## Installation
To install the `dtools` script, run the following command:

```shell
curl -fsSL https://raw.githubusercontent.com/Dark-Alex-17/dtools/refs/heads/main/scripts/install.sh | bash
```

This will install `dtools` to `~/.local/bin/dtools`, and install the tab completions to your `~./bashrc`. So be sure to 
`source ~/.bashrc` to enable the completions.

Just run `dtools --help` to get started!

---
## Features

### 🤖 AI & Local LLMs
- Chat with local models via llama.cpp
- Start and manage llama.cpp servers
- Quick access to Llama API documentation and UI

### ☁️ Cloud & Infrastructure
**AWS**:
- SSO login with automatic credential management
- Open AWS console directly to any service
- Interactive AWS CLI shell
- EC2: List/describe instances, SSH tunneling, start/stop instances
- RDS: Connect to databases, port forwarding
- CloudWatch Logs: Tail log groups, query logs
- Secrets Manager: Retrieve and manage secrets
- SSM: Session manager, parameter store access, bastion instance management

**GCP**:
- Artifact Registry: Docker login, list repositories
- Vertex AI: Model management and deployment

### 🗄️ Databases
- Spin up PostgreSQL in Docker with optional persistence
- Interactive database TUI (Harlequin)
- Dump databases to SQL or DBML format
- Database schema visualization

### 📊 Data Visualization & Utilities
- Plot data from stdin or files (line/bar charts)
- Real-time plotting for live data streams
- Date/epoch conversion utilities
- Random number generation (int/float)
- ISO 8601 date formatting

### 🔧 Development Tools
**Java**:
- Switch between Java versions (8, 11, 17, 21)
- SonarQube static analysis integration

**Git**:
- Search entire git history for strings

**Elastic Stack**:
- Initialize and manage local Elasticsearch + Kibana + Logstash

**Docker**:
- Clean images, containers, and volumes

### 📝 Document Processing
- Convert between formats using pandoc (Markdown, HTML, PDF, DOCX, etc.)
- View markdown files with live preview

### 🌐 Network Tools
- Generate self-signed HTTPS certificates
- Start simple HTTP servers with netcat
- Network scanning and monitoring (documentation)

### 🔒 Security & Ansible
**Ansible**:
- Encrypt/decrypt strings and variables with Ansible Vault

**Pentesting** (Documentation):
- Reference commands for reconnaissance and testing tools
- Network analysis examples
- Security testing workflows

### 💻 Virtual Machines
- Spin up Windows VMs with FreeRDP
- Configurable disk size, RAM, and CPU cores
- Share directories between host and VM
- Persistent VM storage

### 🎬 Video & Media
- Rip audio from video files with metadata support

### 🧹 System Maintenance
- Clean system with BleachBit
- Clean Docker resources
- Clear package manager caches
- Purge old logs and journal entries
- Recursively clean build caches (npm, gradle, maven, etc.)

### 🔔 Notifications
- Subscribe to ntfy topics with optional sound alerts
- Quick reference for ntfy message publishing

### 📦 Installation Helpers
- Install Docker on Debian systems
- Install Ansible
- Install Java LTS versions (8, 11, 17, 21)

### 🛠️ Miscellaneous
- Interactive file selection with fzf integration
- Backup files and directories
- Generate secure passwords
- Record terminal sessions as GIFs
- Play mp3 sounds from CLI
- View markdown with GitHub-style rendering

### 📚 TUI Reference Library
Documentation commands that reference useful TUIs for:
- System monitoring (htop, btop, etc.)
- Network monitoring
- Docker management
- Development workflows
- Data exploration
- AI tools

## Building
To build the `dtools` script after making some changes, run the `build` target in the [`Makefile`](./Makefile):

```shell
make build
```

## Running the CLI
Assuming you've already run `make install`, the script should now be available on your `PATH`, so running it is as simple as:
`dtools --help`
