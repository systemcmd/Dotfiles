@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

echo 📥 Dotfiles indiriliyor...
git clone https://github.com/systemcmd/Dotfiles.git %USERPROFILE%\.dotfiles
cd %USERPROFILE%\.dotfiles

echo 🔧 Scoop kontrol ediliyor...
where scoop >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    powershell -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; iwr -useb get.scoop.sh | iex"
)

echo 🧰 Araçlar yükleniyor...
scoop install git neovim fzf delta

echo 🔗 Dotfiles bağlanıyor...
if exist windows\_vimrc (
    mklink %USERPROFILE%\.vimrc %USERPROFILE%\.dotfiles\windows\_vimrc
)
if exist windows\_gitconfig (
    mklink %USERPROFILE%\.gitconfig %USERPROFILE%\.dotfiles\windows\_gitconfig
)

echo ✅ Kurulum tamamlandı! Yeni terminal açabilirsiniz.
pause
