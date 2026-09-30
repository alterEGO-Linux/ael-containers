#!/usr/bin/env bash
# =============================================================================
# INFO
# =============================================================================
# [/ael-containers/install.sh]
# 
# Author      : Pascal Malouin (https://github.com/alterEGO-Linux)
# Created     : 2026-09-30 18:21:53 UTC
# Updated     : 2026-09-30 18:21:53 UTC
# Description : AEL//Containers install script.
# -----------------------------------------------------------------------------

set -euo pipefail

APP="ael-containers"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

BIN_HOME="${HOME}/.local/bin"
DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"

BIN_DIR="${AEL_CONTAINERS_BIN_DIR:-${BIN_HOME}}"
GLOBAL_DIR="${AEL_CONTAINERS_DATA_DIR:-${DATA_HOME}/${APP}}"
PRIVATE_DIR="${AEL_CONTAINERS_CONFIG_DIR:-${CONFIG_HOME}/${APP}}"

die() {
    printf '[!] %s\n' "$*" >&2
    exit 1
}

info() {
    printf '[*] %s\n' "$*"
}

ok() {
    printf '[+] %s\n' "$*"
}

command -v python3 >/dev/null 2>&1 || die "python3 is required"
python3 - <<'PY' || exit 1
import sys
if sys.version_info < (3, 11):
    raise SystemExit("[!] Python 3.11 or newer is required (tomllib is used).")
PY

command -v docker >/dev/null 2>&1 ||
    info "Docker was not found in PATH. AEL//Containers will install, but container actions require Docker."

[[ -f "${SCRIPT_DIR}/ael-containers" ]] ||
    die "Missing ${SCRIPT_DIR}/ael-containers"
[[ -d "${SCRIPT_DIR}/configs" ]] ||
    die "Missing ${SCRIPT_DIR}/configs"

mkdir -p "${BIN_DIR}" "${GLOBAL_DIR}" "${PRIVATE_DIR}"

install -m 0755 "${SCRIPT_DIR}/ael-containers" "${BIN_DIR}/ael-containers"
ok "Installed executable: ${BIN_DIR}/ael-containers"

shopt -s nullglob
configs=("${SCRIPT_DIR}"/configs/*.toml)
for src in "${configs[@]}"; do
    dest="${GLOBAL_DIR}/$(basename -- "${src}")"
    install -m 0644 "${src}" "${dest}"
    ok "Installed global config: ${dest}"
done
shopt -u nullglob

# The private directory is user-owned. We create it if absent but never seed,
# replace, or remove user TOMLs here.
ok "Private config directory: ${PRIVATE_DIR}"

case ":${PATH}:" in
    *":${BIN_DIR}:"*) ;;
    *) info "${BIN_DIR} is not currently in PATH." ;;
esac

printf '\n'
ok "AEL//Containers installed."
printf '    Global catalog : %s\n' "${GLOBAL_DIR}"
printf '    Private configs: %s\n' "${PRIVATE_DIR}"
printf '\n'
printf 'Try: ael-containers list\n'
