# Cekirdek: kabuk secenekleri, tamamlama, modern araclar

setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
setopt INTERACTIVE_COMMENTS EXTENDED_GLOB NO_BEEP
setopt HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY INC_APPEND_HISTORY

# Tamamlama: menu secimi, buyuk/kucuk harf duyarsiz, renkli
if (( ! ${+_comps} )); then
  autoload -Uz compinit && compinit -C
fi
zmodload zsh/complist 2>/dev/null
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format "%F{${SC_COLOR[purple]}}-- %d --%f"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$SYSTEMCMD_HOME/zcompcache"

# Duzenleme kisayollari
bindkey -e
bindkey '^[[1;3D' backward-word   # Alt+Sol
bindkey '^[[1;3C' forward-word    # Alt+Sag
bindkey '^[b' backward-word
bindkey '^[f' forward-word
bindkey '^[[3~' delete-char
bindkey '^U' backward-kill-line
autoload -Uz edit-command-line && zle -N edit-command-line
bindkey '^X^E' edit-command-line  # komutu nvim'de duzenle

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"

# Onizleme komutu: bat varsa renkli, klasorse agac
if command -v bat >/dev/null; then
  export BAT_THEME="${BAT_THEME:-ansi}"
  typeset -g SC_PREVIEW_FILE='bat --style=numbers --color=always --paging=never --line-range :300'
else
  typeset -g SC_PREVIEW_FILE='head -300'
fi
if command -v eza >/dev/null; then
  typeset -g SC_PREVIEW_DIR='eza --tree --level=2 --icons=always --color=always --group-directories-first'
else
  typeset -g SC_PREVIEW_DIR='ls -la'
fi
export SC_PREVIEW="if [ -d {} ]; then $SC_PREVIEW_DIR {}; else $SC_PREVIEW_FILE {}; fi"

# Modern araclar (kuruluysa)
if command -v eza >/dev/null; then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --group-directories-first --git --time-style=relative'
  alias la='eza -la --icons=auto --group-directories-first --git --time-style=relative'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
else
  alias ls='ls -G'
  alias ll='ls -lhG'
  alias la='ls -lhAG'
fi
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'
command -v btop >/dev/null && alias top='btop'
command -v lazygit >/dev/null && alias lg='lazygit'
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"   # z <parca>, zi = interaktif
fi
if command -v delta >/dev/null && [[ -z "$GIT_PAGER" ]]; then
  export GIT_PAGER='delta'
  export DELTA_FEATURES='+line-numbers +navigate'
fi

alias reload='exec zsh'
alias path='print -rl -- $path'
alias ports='sc ports'
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }

# ── W11 profil alias/fonksiyonlari (macOS uyarlamasi) ───────────────────────
alias c='clear'
alias sil='clear'
command -v nvim >/dev/null && alias vim='nvim'
command -v tig  >/dev/null && alias tig='tig'
alias ifconfig='ipconfig getifaddr en0; command ifconfig'
alias st='open'              # Windows'ta Start-Process -> macOS'ta open
rmrf() { rm -rf -- "$@"; }   # W11 rmrf
which() {                    # W11 'which' = Get-Command benzeri, tum turleri goster
  local a
  for a in "$@"; do whence -va "$a"; done
}
