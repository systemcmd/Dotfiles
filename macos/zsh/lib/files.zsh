# Ctrl+F: hizli dosya secici
#   - imlecin altindaki kelime bir klasorse o klasorun icini acar
#   - degilse bulundugun klasorde o kelimeyle arar
#   Tab: coklu secim | Ctrl+/: onizleme | Alt+H: gizli dosyalar

typeset -g SYSTEMCMD_FZF_SKIP_DIRS='.git,node_modules,dist,build,target,.venv,venv,__pycache__,.next,.nuxt,.cache,vendor,coverage,.dart_tool,Pods,.gradle,DerivedData'

_sc_list_files() {
  local root="$1" hidden="${2:-0}"
  if command -v fd >/dev/null; then
    local -a ex=()
    local d
    for d in ${(s:,:)SYSTEMCMD_FZF_SKIP_DIRS}; do ex+=(--exclude "$d"); done
    (( hidden )) && ex+=(--hidden)
    ( cd "$root" && fd --color=always --follow "${ex[@]}" 2>/dev/null )
  else
    ( cd "$root" && find . -mindepth 1 \( -name .git -o -name node_modules -o -name .dart_tool -o -name build -o -name Pods \) -prune -o -print 2>/dev/null | sed 's#^\./##' )
  fi
}

sc-file-widget() {
  command -v fzf >/dev/null || { zle -M 'fzf bulunamadi'; return 1; }

  local word="${LBUFFER##* }" root="$PWD" query
  local expanded="${word/#\~/$HOME}"
  if [[ -n "$word" && -d "$expanded" ]]; then
    root="${expanded:A}"; query=''
  else
    query="$word"
  fi

  local -a picked
  picked=("${(@f)$(
    cd "$root" && _sc_list_files "$root" |
      fzf --ansi --multi --height=80% --scheme=path \
        --prompt="files ${root/#$HOME/~} > " --border-label=' systemcmd ' \
        --header='Tab: coklu secim | Ctrl+/: onizleme | Alt+H: gizli' \
        --preview="$SC_PREVIEW" --preview-window='right,60%,wrap,border-left' \
        --bind='ctrl-/:toggle-preview' \
        --bind="alt-h:reload(zsh -c 'source ${(q)SYSTEMCMD_ROOT}/lib/files.zsh; _sc_list_files ${(q)root} 1')" \
        --query="$query"
  )}")
  (( ${#picked} )) && [[ -n "${picked[1]}" ]] || { zle reset-prompt; return 0; }

  local p out=()
  for p in "${picked[@]}"; do
    [[ "$root" != "$PWD" ]] && p="${word%/}/$p"
    if [[ "$p" == '~/'* ]]; then out+=("~/${(q-)p#\~/}"); else out+=("${(q-)p}"); fi
  done

  [[ -n "$word" ]] && LBUFFER="${LBUFFER%$word}"
  LBUFFER+="${(j: :)out}"
  zle reset-prompt
}

zle -N sc-file-widget
bindkey '^F' sc-file-widget
