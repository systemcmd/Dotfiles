# systemcmd - native zsh katmani (macOS)
# ~/.zshrc icinden en sona source edilir. PowerShell gerektirmez.

[[ -o interactive ]] || return 0

typeset -g SYSTEMCMD_ROOT="${${(%):-%N}:A:h}"
typeset -g SYSTEMCMD_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/systemcmd"
[[ -d "$SYSTEMCMD_HOME" ]] || mkdir -p "$SYSTEMCMD_HOME"

zmodload zsh/datetime 2>/dev/null
autoload -Uz add-zsh-hook

for _sc_mod in theme core prompt history files git projects ai buddy sysinfo extras menu welcome; do
  source "$SYSTEMCMD_ROOT/lib/${_sc_mod}.zsh"
done
unset _sc_mod
