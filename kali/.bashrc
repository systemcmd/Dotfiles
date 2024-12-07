# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Set history control
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=999999
HISTFILESIZE=999999

# Check the window size after each command
shopt -s checkwinsize

# Enable color prompt
force_color_prompt=yes
if [ "$force_color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi

# Set aliases
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
fi

# Include .bash_aliases if available
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Load fzf if available
if [ -f ~/.fzf.bash ]; then
    source ~/.fzf.bash
else
    echo "Warning: fzf is not installed. Please install it with 'sudo apt install fzf'."
fi

# Functions for system information
get_ram_info() {
    free -m | awk '/^Mem:/ {printf "Used RAM: %.2f GB | ", $3/1024}'
}

get_free_ram_info() {
    free -m | awk '/^Mem:/ {printf "Free RAM: %.2f GB", $4/1024}'
}

get_cpu_info() {
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "CPU Usage: %.1f%%", 100 - $1}'
}

get_local_ip() {
    hostname -I | awk '{print "Local IP: " $1}'
}

generate_systemcmd_header() {
    echo -e "\033[32m?\033[0m systemcmd"
}

fzf-file-widget() {
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
    local selected_command
    selected_command=$(history | fzf --height 40% --layout=reverse --tac --preview 'echo "Komut: {}"' --preview-window=hidden --border --prompt="Select command: ")
    if [[ -n $selected_command ]]; then
        selected_command=$(echo $selected_command | sed 's/^[ 0-9]*//')
        READLINE_LINE="${selected_command}"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

if [ -t 1 ]; then
    bind -x '"\C-f": "fzf-file-widget"'
    bind -x '"\C-r": "fzf-history-widget"'
fi


