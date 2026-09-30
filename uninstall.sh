#!/usr/bin/env bash
# =============================================================================
# INFO
# =============================================================================
# [/ael-containers/uninstall.sh]
# 
# Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
# Created     : 2026-09-30 18:22:58 UTC
# Updated     : 2026-09-30 18:22:58 UTC
# Description : AEL//containers uninstall script.
# -----------------------------------------------------------------------------

set -euo pipefail

APP="ael-containers"

BIN_HOME="${HOME}/.local/bin"
DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

BIN_DIR="${AEL_CONTAINERS_BIN_DIR:-${BIN_HOME}}"
GLOBAL_DIR="${AEL_CONTAINERS_DATA_DIR:-${DATA_HOME}/${APP}}"
PRIVATE_DIR="${AEL_CONTAINERS_CONFIG_DIR:-${CONFIG_HOME}/${APP}}"

info() {
    printf '[*] %s\n' "$*"
}

ok() {
    printf '[+] %s\n' "$*"
}

if [[ -e "${BIN_DIR}/ael-containers" ]]; then
    rm -f -- "${BIN_DIR}/ael-containers"
    ok "Removed executable: ${BIN_DIR}/ael-containers"
else
    info "Executable not installed: ${BIN_DIR}/ael-containers"
fi

# This directory is AEL-owned by definition.
if [[ -d "${GLOBAL_DIR}" ]]; then
    rm -rf -- "${GLOBAL_DIR}"
    ok "Removed global catalog: ${GLOBAL_DIR}"
else
    info "Global catalog not found: ${GLOBAL_DIR}"
fi

# Never delete user-owned TOMLs.
if [[ -d "${PRIVATE_DIR}" ]]; then
    ok "Preserved private configs: ${PRIVATE_DIR}"
fi

printf '\n'
ok "AEL//Containers uninstalled."
printf 'Docker containers, images, volumes, and user-owned configs were not removed.\n'
