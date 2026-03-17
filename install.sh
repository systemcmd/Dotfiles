#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/systemcmd/Dotfiles.git"
SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TEMP_ROOT=""

log() {
  printf '[systemcmd] %s\n' "$1"
}

warn() {
  printf '[systemcmd] %s\n' "$1" >&2
}

cleanup() {
  if [[ -n "${TEMP_ROOT}" && -d "${TEMP_ROOT}" ]]; then
    rm -rf "${TEMP_ROOT}"
  fi
}

trap cleanup EXIT

resolve_source_dir() {
  if [[ -f "${SCRIPT_DIR}/linux/systemcmd.bashrc" ]]; then
    printf '%s\n' "${SCRIPT_DIR}"
    return
  fi

  TEMP_ROOT="$(mktemp -d)"

  if command -v git >/dev/null 2>&1; then
    log "Git ile kaynak dosyalar indiriliyor."
    git clone --depth 1 "${REPO_URL}" "${TEMP_ROOT}/Dotfiles" >/dev/null 2>&1
    printf '%s\n' "${TEMP_ROOT}/Dotfiles"
    return
  fi

  if command -v curl >/dev/null 2>&1; then
    log "Zip arsivi indiriliyor."
    curl -fsSL "https://github.com/systemcmd/Dotfiles/archive/refs/heads/main.tar.gz" | tar -xz -C "${TEMP_ROOT}"
    printf '%s\n' "${TEMP_ROOT}/Dotfiles-main"
    return
  fi

  warn "Ne git ne de curl bulundu. Kurulum devam edemiyor."
  exit 1
}

ensure_sudo_prefix() {
  if [[ "$(id -u)" -eq 0 ]]; then
    printf '%s\n' ""
    return
  fi

  if command -v sudo >/dev/null 2>&1; then
    printf '%s\n' "sudo"
    return
  fi

  printf '%s\n' ""
}

install_packages() {
  local sudo_cmd
  sudo_cmd="$(ensure_sudo_prefix)"

  if command -v apt-get >/dev/null 2>&1; then
    log "apt ile gerekli paketler yukleniyor."
    ${sudo_cmd} apt-get update
    ${sudo_cmd} apt-get install -y bash curl git fzf bat
    return
  fi

  if command -v dnf >/dev/null 2>&1; then
    log "dnf ile gerekli paketler yukleniyor."
    ${sudo_cmd} dnf install -y bash curl git fzf bat
    return
  fi

  if command -v pacman >/dev/null 2>&1; then
    log "pacman ile gerekli paketler yukleniyor."
    ${sudo_cmd} pacman -Sy --noconfirm bash curl git fzf bat
    return
  fi

  if command -v zypper >/dev/null 2>&1; then
    log "zypper ile gerekli paketler yukleniyor."
    ${sudo_cmd} zypper --non-interactive install bash curl git fzf bat
    return
  fi

  if command -v apk >/dev/null 2>&1; then
    log "apk ile gerekli paketler yukleniyor."
    ${sudo_cmd} apk add bash curl git fzf bat
    return
  fi

  warn "Desteklenen bir paket yoneticisi bulunamadi. Paketleri manuel kurmaniz gerekebilir."
}

install_systemcmd_profile() {
  local source_dir="$1"
  local config_dir="${HOME}/.config/systemcmd"
  local target_file="${config_dir}/systemcmd.bashrc"
  local bashrc_file="${HOME}/.bashrc"
  local bootstrap_line='[ -f "$HOME/.config/systemcmd/systemcmd.bashrc" ] && . "$HOME/.config/systemcmd/systemcmd.bashrc"'

  mkdir -p "${config_dir}"
  cp "${source_dir}/linux/systemcmd.bashrc" "${target_file}"

  if [[ ! -f "${bashrc_file}" ]]; then
    touch "${bashrc_file}"
  fi

  if ! grep -Fq 'systemcmd bootstrap' "${bashrc_file}"; then
    cp "${bashrc_file}" "${bashrc_file}.systemcmd.bak.$(date +%Y%m%d%H%M%S)"
    {
      printf '\n# systemcmd bootstrap\n'
      printf '%s\n' "${bootstrap_line}"
    } >> "${bashrc_file}"
  fi
}

main() {
  local source_dir
  source_dir="$(resolve_source_dir)"

  if [[ ! -f "${source_dir}/linux/systemcmd.bashrc" ]]; then
    warn "Linux profil dosyasi bulunamadi."
    exit 1
  fi

  install_packages
  install_systemcmd_profile "${source_dir}"

  log "Kurulum tamamlandi."
  log "Yeni bir terminal acip 'system' komutunu kullanabilirsiniz."
}

main "$@"
