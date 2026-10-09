#!/usr/bin/env bash
# systemcmd macOS kurulumu: native zsh katmani + Ghostty + modern araclar
#
#   bash macos/install.sh            # paketler + kurulum (repo'ya symlink, gelistirme icin)
#   bash macos/install.sh --copy     # repo yerine kopya kur
#   bash macos/install.sh --no-brew  # Homebrew paketlerini atla
set -euo pipefail

SOURCE_DIR="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname -- "${SOURCE_DIR}")"
DEST_ROOT="${HOME}/.local/share/systemcmd"
DEST="${DEST_ROOT}/macos"
CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
STAMP="$(date +%Y%m%d-%H%M%S)"
MODE=link
BREW=1

for arg in "$@"; do
  case "${arg}" in
    --copy) MODE=copy ;;
    --no-brew) BREW=0 ;;
    *) echo "Bilinmeyen secenek: ${arg}" >&2; exit 2 ;;
  esac
done

log()  { printf '\033[38;2;94;255;195m[systemcmd]\033[0m %s\n' "$1"; }
warn() { printf '\033[38;2;211;132;84m[systemcmd]\033[0m %s\n' "$1" >&2; }

backup() {
  # Var olan dosya/klasoru (symlink degilse) yedekler
  local target="$1"
  if [[ -e "${target}" && ! -L "${target}" ]]; then
    mv "${target}" "${target}.backup-${STAMP}"
    log "Yedek: ${target}.backup-${STAMP}"
  elif [[ -L "${target}" ]]; then
    rm "${target}"
  fi
}

# 1) Paketler
if [[ "${BREW}" == 1 ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    warn 'Homebrew gerekli: https://brew.sh'; exit 1
  fi
  log 'Homebrew paketleri kuruluyor (Brewfile)...'
  brew bundle --file "${SOURCE_DIR}/Brewfile" || warn 'Bazi paketler kurulamadi, devam ediliyor.'
fi

# 2) systemcmd dosyalari
mkdir -p "${DEST_ROOT}"
backup "${DEST}"
if [[ "${MODE}" == link ]]; then
  ln -s "${SOURCE_DIR}" "${DEST}"
  log "Bagli kurulum: ${DEST} -> ${SOURCE_DIR} (repo'daki degisiklikler aninda gecerli)"
else
  cp -R "${SOURCE_DIR}" "${DEST}"
  log "Kopya kurulum: ${DEST}"
fi

# 3) Ghostty
mkdir -p "${CONFIG_HOME}/ghostty"
GHOSTTY_CONFIG="${CONFIG_HOME}/ghostty/config"
if [[ -L "${GHOSTTY_CONFIG}" ]] || ! grep -q 'systemcmd' "${GHOSTTY_CONFIG}" 2>/dev/null; then
  backup "${GHOSTTY_CONFIG}"
else
  rm -f "${GHOSTTY_CONFIG}"
fi
if [[ "${MODE}" == link ]]; then
  ln -s "${SOURCE_DIR}/terminal/ghostty/config" "${GHOSTTY_CONFIG}"
else
  cp "${SOURCE_DIR}/terminal/ghostty/config" "${GHOSTTY_CONFIG}"
fi
zsh -c "SYSTEMCMD_ROOT='${DEST}/zsh'; SYSTEMCMD_HOME='${CONFIG_HOME}/systemcmd'; mkdir -p \"\$SYSTEMCMD_HOME\"; source '${DEST}/zsh/lib/theme.zsh'; sc_theme_write_ghostty"
log "Ghostty ayarlari: ${GHOSTTY_CONFIG}"

# 4) Neovim (yoksa)
if [[ ! -e "${CONFIG_HOME}/nvim" && -d "${REPO_DIR}/nvim" ]]; then
  if [[ "${MODE}" == link ]]; then ln -s "${REPO_DIR}/nvim" "${CONFIG_HOME}/nvim"; else cp -R "${REPO_DIR}/nvim" "${CONFIG_HOME}/nvim"; fi
  log "Neovim ayarlari: ${CONFIG_HOME}/nvim"
fi

# 5) ~/.zshrc: eski bloklari kaldir, yeni bootstrap ekle
ZSHRC="${HOME}/.zshrc"
touch "${ZSHRC}"
cp "${ZSHRC}" "${ZSHRC}.backup-${STAMP}"
log "Yedek: ${ZSHRC}.backup-${STAMP}"
awk '
  /^# >>> SYSTEMCMD/ { skip = 1; next }
  /^# <<< SYSTEMCMD/ { skip = 0; next }
  !skip
' "${ZSHRC}.backup-${STAMP}" > "${ZSHRC}"
cat >> "${ZSHRC}" <<EOF
# >>> SYSTEMCMD native zsh >>>
[[ -f '${DEST}/zsh/systemcmd.zsh' ]] && source '${DEST}/zsh/systemcmd.zsh'
# <<< SYSTEMCMD native zsh <<<
EOF
log "~/.zshrc guncellendi."

cat <<'EOF'

  Kurulum tamam. Simdi:
    1. Ghostty'yi ac (Uygulamalar > Ghostty)
    2. Alt+Space ile her yerden acmak icin: Sistem Ayarlari > Gizlilik > Erisilebilirlik > Ghostty'ye izin ver
    3. sc keys   -> tum kisayollar
       sc doctor -> kontrol

EOF
