#!/usr/bin/env bash
# Common functions and color definitions for dsxtool

set -euo pipefail

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Logging functions
log_info() {
    echo -e "${GREEN}[INFO]${RESET} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${RESET} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${RESET} $*"
}

# Exit with error message
die() {
    log_error "$*"
    exit 1
}

# Check if running with sudo privileges when needed
require_sudo() {
    if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
        die "This command requires root privileges or passwordless sudo."
    fi
}

# Wait for user to continue
prompt_continue() {
    read -rp "$(echo -e "${YELLOW}Press Enter to continue...${RESET}")"
}
