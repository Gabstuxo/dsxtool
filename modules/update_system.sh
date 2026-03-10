#!/usr/bin/env bash
set -euo pipefail

update_system() {
    log_info "Updating system..."
    pkg_update
    log_info "System update completed."
}
