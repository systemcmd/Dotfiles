# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=999999
HISTFILESIZE=999999

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
    else
    color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u\[\033[01;33m\]@\[\033[01;36m\]\h \[\033[01;33m\]\w \[\033[01;35m\]\$ \[\033[00m\]'
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
#alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Load fzf
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Function to get system RAM info
get_ram_info() {
    free -m | awk '/^Mem:/ {printf "Used RAM: %.2f GB | ", $3/1024}'
}

# Function to get free RAM info
get_free_ram_info() {
    free -m | awk '/^Mem:/ {printf "Free RAM: %.2f GB", $4/1024}'
}

# Function to get CPU usage
get_cpu_info() {
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{printf "CPU Usage: %.1f%%", 100 - $1}'
}

# Function to get local IP address
get_local_ip() {
    hostname -I | awk '{print "Local IP: " $1}'
}

# Function to generate systemcmd header with a rotating green icon
generate_systemcmd_header() {
    echo -e "\033[32m?\033[0m systemcmd"  # This is a static representation of a rotating arrow
}

# Set up Ctrl+f key binding for fzf
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

# Set up Ctrl+r key binding for fzf
fzf-history-widget() {
    local selected_command
    selected_command=$(history | fzf --height 40% --layout=reverse --tac --preview 'echo "Komut: {}"' --preview-window=hidden --border --prompt="Select command: ")
    if [[ -n $selected_command ]]; then
        selected_command=$(echo $selected_command | sed 's/^[ 0-9]*//')  # Remove leading command number and spaces
        READLINE_LINE="${selected_command}"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

if [ -t 1 ]; then
    bind -x '"\C-f": "fzf-file-widget"'
    bind -x '"\C-r": "fzf-history-widget"'
fi
