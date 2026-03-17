# shellcheck shell=bash

case $- in
  *i*) ;;
  *) return ;;
esac

if [[ -f "${HOME}/.config/systemcmd/systemcmd.bashrc" ]]; then
  # shellcheck disable=SC1090
  . "${HOME}/.config/systemcmd/systemcmd.bashrc"
  return
fi

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---height 70% --layout=reverse --border}"

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
  alias ls='ls --color=auto'
fi

alias ll='ls -alF'

system() {
  printf 'systemcmd yuklu degil. install.sh ile kurulum yapin.\n'
}
