#!/bin/bash
set -e

echo "📥 Dotfiles indiriliyor..."
git clone https://github.com/systemcmd/Dotfiles.git "$HOME/.dotfiles" || {
  echo "⚠️ Zaten var. Güncelleniyor..."
  cd "$HOME/.dotfiles" && git pull
}

cd "$HOME/.dotfiles"

echo "🔧 Gerekli paketler yükleniyor..."
sudo apt update && sudo apt install -y git stow zsh tmux vim curl

echo "🔗 Dotfiles symlink işlemi başlatılıyor..."
for dir in bash zsh vim tmux; do
  if [ -d "$dir" ]; then
    stow "$dir"
  fi
done

echo "✅ Kurulum tamamlandı! Terminali yeniden başlatabilirsiniz."
