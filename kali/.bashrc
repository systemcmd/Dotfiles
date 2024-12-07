# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History control
if command -v bash &>/dev/null; then
    HISTCONTROL=ignoreboth
    shopt -s histappend &>/dev/null
    shopt -s checkwinsize &>/dev/null
else
    echo -e "\033[1;31mWarning: 'bash' veya 'shopt' komutu eksik. Bash düzgün yapılandırılmamış olabilir.\033[0m"
    echo -e "\033[1;31mKurmak için: sudo apt install --reinstall bash\033[0m"
    echo -e "\033[1;31mVarsayılan shell'i bash yapmak için: chsh -s /bin/bash\033[0m"
    echo -e "\033[1;31mShell kontrolü için: echo \$SHELL\033[0m"
fi

HISTSIZE=999999
HISTFILESIZE=999999

# Enable color prompt
force_color_prompt=yes
if [ "$force_color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]$ \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Check and load dircolors
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
else
    echo -e "\033[1;31mWarning: 'dircolors' komutu eksik. Renkli 'ls' desteği aktif değil.\033[0m"
    echo -e "\033[1;31mKurmak için: sudo apt install coreutils\033[0m"
fi

# Load .bash_aliases if available
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable bash-completion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion &>/dev/null
else
    echo -e "\033[1;31mWarning: 'bash-completion' eksik. Komut tamamlama çalışmayabilir.\033[0m"
    echo -e "\033[1;31mKurmak için: sudo apt install bash-completion\033[0m"
fi

# Load fzf if available
if command -v fzf &>/dev/null; then
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
else
    echo -e "\033[1;31mWarning: 'fzf' yüklü değil. Dosya ve geçmiş araması yapılamayabilir.\033[0m"
    echo -e "\033[1;31mKurmak için: sudo apt install fzf\033[0m"
fi

# Functions for system information
get_ram_info() {
    free -m 2>/dev/null | awk '/^Mem:/ {printf "Used RAM: %.2f GB | ", $3/1024}'
}

get_free_ram_info() {
    free -m 2>/dev/null | awk '/^Mem:/ {printf "Free RAM: %.2f GB", $4/1024}'
}

get_cpu_info() {
    if command -v top &>/dev/null; then
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "CPU Usage: %.1f%%", 100 - $1}'
    else
        echo "CPU bilgisi alınamıyor."
    fi
}

get_local_ip() {
    if command -v hostname &>/dev/null; then
        hostname -I | awk '{print "Local IP: " $1}'
    else
        echo "IP bilgisi alınamıyor."
    fi
}

generate_systemcmd_header() {
    echo -e "\033[32m?\033[0m systemcmd"
}

fzf-file-widget() {
    if ! command -v fzf &>/dev/null; then
        echo -e "\033[1;31mHata: 'fzf' kurulu değil. Kurmak için: sudo apt install fzf\033[0m"
        return
    fi

    local selected_file
    local ram_info=$(get_ram_info)
    local free_ram_info=$(get_free_ram_info)
    local cpu_info=$(get_cpu_info)
    local local_ip=$(get_local_ip)
    local sys_cmd_header=$(generate_systemcmd_header)

    selected_file=$(fzf --height 40% --layout=reverse --preview "cat {}" --preview-window=up:70% --border --header="$ram_info  |  $free_ram_info  |  $cpu_info  |  $local_ip  |  $sys_cmd_header" --prompt="Select file: ")

    if [[ -n $selected_file ]]; then
        READLINE_LINE="${READLINE_LINE}${selected_file}"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

fzf-history-widget() {
    if ! command -v fzf &>/dev/null; then
        echo -e "\033[1;31mHata: 'fzf' kurulu değil. Kurmak için: sudo apt install fzf\033[0m"
        return
    fi

    local selected_command
    selected_command=$(history | fzf --height 40% --layout=reverse --tac --preview 'echo "Komut: {}"' --preview-window=hidden --border --prompt="Select command: ")
    if [[ -n $selected_command ]]; then
        selected_command=$(echo $selected_command | sed 's/^[ 0-9]*//')
        READLINE_LINE="${selected_command}"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

# Bind kontrolü kaldırıldı
if command -v bind &>/dev/null; then
    bind -x '"\C-f": "fzf-file-widget"'
    bind -x '"\C-r": "fzf-history-widget"'
fi


