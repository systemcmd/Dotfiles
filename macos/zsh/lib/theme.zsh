# Tema: palet yukleme, fzf renkleri, Ghostty tema dosyasi

typeset -gA SC_COLOR
typeset -g SYSTEMCMD_THEME_FILE="$SYSTEMCMD_HOME/theme"
typeset -g SYSTEMCMD_GHOSTTY_THEME="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/systemcmd-theme"

sc_theme_names() {
  local f
  for f in "$SYSTEMCMD_ROOT"/themes/*.zsh(N); do print -r -- "${f:t:r}"; done
}

sc_theme_current() {
  local name
  [[ -r "$SYSTEMCMD_THEME_FILE" ]] && name="$(<"$SYSTEMCMD_THEME_FILE")"
  [[ -n "$name" && -r "$SYSTEMCMD_ROOT/themes/$name.zsh" ]] || name=systemcmd
  print -r -- "$name"
}

sc_theme_load() {
  local name="${1:-$(sc_theme_current)}"
  SC_COLOR=()
  source "$SYSTEMCMD_ROOT/themes/$name.zsh"
  typeset -g SYSTEMCMD_THEME_NAME="$name"

  export SYSTEMCMD_FZF_COLOR="fg:${SC_COLOR[fg]},fg+:${SC_COLOR[green]},bg:-1,bg+:${SC_COLOR[selection]},gutter:-1,prompt:${SC_COLOR[cyan]},pointer:${SC_COLOR[magenta]},marker:${SC_COLOR[green]},spinner:${SC_COLOR[cyan]},hl:${SC_COLOR[blue]},hl+:${SC_COLOR[cyan]},info:${SC_COLOR[muted]},border:${SC_COLOR[surface]},preview-border:${SC_COLOR[surface]},header:${SC_COLOR[muted]},label:${SC_COLOR[cyan]}"
  # --no-mouse: fzf fareyi/trackpad'i yakalamasin (cikinca iz birakip prompt'a
  # fare kodlari yaziyordu). Zaten klavyeyle kullaniliyor.
  export FZF_DEFAULT_OPTS="--no-mouse --layout=reverse --border=rounded --cycle --info=inline-right --color=${SYSTEMCMD_FZF_COLOR}"

  # zsh-autosuggestions / zsh-syntax-highlighting yuklendiyse renklerini paletten al
  typeset -g ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=${SC_COLOR[muted]}"
  typeset -gA ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[command]="fg=${SC_COLOR[green]}"
  ZSH_HIGHLIGHT_STYLES[builtin]="fg=${SC_COLOR[cyan]}"
  ZSH_HIGHLIGHT_STYLES[alias]="fg=${SC_COLOR[green]}"
  ZSH_HIGHLIGHT_STYLES[function]="fg=${SC_COLOR[cyan]}"
  ZSH_HIGHLIGHT_STYLES[precommand]="fg=${SC_COLOR[purple]},underline"
  ZSH_HIGHLIGHT_STYLES[unknown-token]="fg=${SC_COLOR[red]},bold"
  ZSH_HIGHLIGHT_STYLES[path]="fg=${SC_COLOR[fg]},underline"
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]="fg=${SC_COLOR[yellow]}"
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]="fg=${SC_COLOR[yellow]}"
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]="fg=${SC_COLOR[purple]}"
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]="fg=${SC_COLOR[purple]}"
  ZSH_HIGHLIGHT_STYLES[comment]="fg=${SC_COLOR[muted]},italic"
}

# Ghostty icin 16 renklik palet uretir; Ghostty config bunu config-file ile okur.
sc_theme_write_ghostty() {
  local -A c=("${(@kv)SC_COLOR}")
  [[ -d "${SYSTEMCMD_GHOSTTY_THEME:h}" ]] || return 0
  {
    print -r -- "# systemcmd tarafindan uretildi ($SYSTEMCMD_THEME_NAME). Elle duzenleme: sc theme ile degisir."
    print -r -- "background = ${c[bg]}"
    print -r -- "foreground = ${c[fg]}"
    print -r -- "cursor-color = ${c[magenta]}"
    print -r -- "selection-background = ${c[selection]}"
    print -r -- "selection-foreground = ${c[fg]}"
    local i=0 col
    for col in surface red green orange blue magenta cyan fg muted red green yellow blue purple cyan fg; do
      print -r -- "palette = ${i}=${c[$col]}"
      (( i++ ))
    done
  } >| "$SYSTEMCMD_GHOSTTY_THEME"
}

sc_theme_set() {
  local name="$1"
  if [[ -z "$name" ]]; then
    command -v fzf >/dev/null || { sc_theme_names; return; }
    name="$(sc_theme_names | fzf --height=40% --prompt='tema > ' --header="Su an: $SYSTEMCMD_THEME_NAME")" || return
  fi
  if [[ ! -r "$SYSTEMCMD_ROOT/themes/$name.zsh" ]]; then
    print -P "%F{red}Tema yok:%f $name  (mevcut: ${(j:, :)${(f)$(sc_theme_names)}})"
    return 1
  fi
  print -r -- "$name" >| "$SYSTEMCMD_THEME_FILE"
  sc_theme_load "$name"
  sc_theme_write_ghostty
  # Ghostty'ye yeniden yukleme sinyali yok; aktif pencere icin OSC ile renkleri hemen uygula
  printf '\e]10;%s\a\e]11;%s\a\e]12;%s\a' "${SC_COLOR[fg]}" "${SC_COLOR[bg]}" "${SC_COLOR[magenta]}"
  print -P "%F{${SC_COLOR[green]}}Tema:%f $name  %F{${SC_COLOR[muted]}}(Ghostty: Cmd+Shift+, ile tam yenile)%f"
}

sc_theme_load
