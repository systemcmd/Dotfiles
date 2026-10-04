#!/usr/bin/env bash
set -euo pipefail

SOURCE_DIR="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v brew >/dev/null 2>&1; then
  echo '[systemcmd] Homebrew gerekli: https://brew.sh' >&2; exit 1
fi

brew install powershell fzf bat neovim git
pwsh -NoLogo -NoProfile -File "${SOURCE_DIR}/scripts/Install-Core.ps1" \
  -Destination "${HOME}/.local/share/systemcmd" \
  -ProfilePath "${HOME}/.config/powershell/profile.ps1" \
  -BashProfile "${HOME}/.bashrc" -ZshProfile "${HOME}/.zshrc"
echo '[systemcmd] Kurulum tamamlandı. Yeni terminalde pwsh açıp systemcmd doctor çalıştırın.'
