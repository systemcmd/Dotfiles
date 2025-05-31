#!/bin/bash

set -e

echo "📥 Dotfiles indiriliyor..."
git clone https://github.com/systemcmd/Dotfiles.git "$HOME/.dotfiles"

cd "$HOME/.dotfiles"

echo "🔧 Gerekli paketler yükleniyor..."
sudo apt update && sudo apt install -y git stow zsh tmux vim curl

echo "🔗 Dotfiles symlink işlemi başlatılıyor..."
cd "$HOME/.dotfiles"
stow bash
stow zsh
stow vim
stow tmux

echo "✅ Kurulum tamamlandı! Terminali yeniden başlatabilirsiniz."
