# Prompt: iki satirli, git + proje + sure + hata kodu
#
#  ╭─  ~/Desktop/paranabiz   main ✚2 ●1 ↑1   flutter        3.2s
#  ╰─❯

typeset -g SC_ICONS="${SYSTEMCMD_ICONS:-1}"
typeset -g _sc_cmd_start=0 _sc_last_status=0 _sc_last_duration=""

typeset -gA SC_ICON
if (( SC_ICONS )); then
  SC_ICON=(os $'\uf179' dir $'\uf07b' home $'\uf015' git $'\ue725' ahead '↑' behind '↓'
           staged '✚' dirty '●' untracked '?' stash '≡' clock $'\uf017' err $'\uf00d'
           flutter $'\ue7dd' node $'\ued0d' python $'\ue73c' rust $'\ue7a8' go $'\ue627'
           swift $'\ue755' android $'\ue70e' docker $'\uf308' dotnet $'\ue77f' ssh $'\uf489')
else
  SC_ICON=(os '' dir '' home '~' git 'git:' ahead '^' behind 'v' staged '+' dirty '*'
           untracked '?' stash '$' clock '' err 'x' flutter 'flutter' node 'node'
           python 'py' rust 'rs' go 'go' swift 'swift' android 'android' docker 'docker'
           dotnet '.net' ssh 'ssh')
fi

# Prompt icinde % karakterini kacir (branch/klasor adi enjeksiyonunu engeller)
_sc_esc() { print -r -- "${1//\%/%%}"; }

_sc_git_segment() {
  local line branch="" oid="" ahead=0 behind=0 staged=0 dirty=0 untracked=0
  local out
  out="$(command git status --porcelain=v2 --branch --no-renames 2>/dev/null)" || return
  for line in "${(@f)out}"; do
    case "$line" in
      '# branch.head '*) branch="${line#\# branch.head }" ;;
      '# branch.oid '*)  oid="${line#\# branch.oid }" ;;
      '# branch.ab '*)   local ab="${line#\# branch.ab }"; ahead="${${ab%% *}#+}"; behind="${${ab##* }#-}" ;;
      '? '*) (( untracked++ )) ;;
      [12u]' '*)
        [[ "${line[3]}" != '.' ]] && (( staged++ ))
        [[ "${line[4]}" != '.' ]] && (( dirty++ ))
        ;;
    esac
  done
  [[ "$branch" == '(detached)' ]] && branch="${oid[1,7]}"

  local s="%F{${SC_COLOR[purple]}}${SC_ICON[git]} $(_sc_esc "$branch")%f"
  (( staged ))    && s+=" %F{${SC_COLOR[green]}}${SC_ICON[staged]}${staged}%f"
  (( dirty ))     && s+=" %F{${SC_COLOR[orange]}}${SC_ICON[dirty]}${dirty}%f"
  (( untracked )) && s+=" %F{${SC_COLOR[muted]}}${SC_ICON[untracked]}${untracked}%f"
  (( ahead ))     && s+=" %F{${SC_COLOR[cyan]}}${SC_ICON[ahead]}${ahead}%f"
  (( behind ))    && s+=" %F{${SC_COLOR[magenta]}}${SC_ICON[behind]}${behind}%f"
  print -r -- "$s"
}

_sc_dir_segment() {
  local dir="${PWD/#$HOME/~}" icon="${SC_ICON[dir]}"
  [[ "$PWD" == "$HOME" ]] && icon="${SC_ICON[home]}"
  # Uzun yollarda ortayi kisalt: ~/a/b/c/d/e -> ~/a/…/d/e
  local -a parts=("${(@s:/:)dir}")
  if (( ${#parts} > 5 )); then
    dir="${parts[1]}/${parts[2]}/…/${parts[-2]}/${parts[-1]}"
  fi
  print -r -- "%B%F{${SC_COLOR[cyan]}}${icon} $(_sc_esc "$dir")%f%b"
}

_sc_prompt_preexec() { _sc_cmd_start=$EPOCHREALTIME; }

_sc_prompt_precmd() {
  _sc_last_status=$?
  # Guvenlik: bir program (fzf, nvim...) fare izleme modunu acik birakmissa kapat
  # ki trackpad'e dokununca prompt'a fare kodlari yazilmasin.
  print -n '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l'
  _sc_last_duration=""
  if (( _sc_cmd_start > 0 )); then
    local elapsed=$(( EPOCHREALTIME - _sc_cmd_start ))
    if (( elapsed >= 60 )); then
      _sc_last_duration="$(( ${elapsed%.*} / 60 ))m$(( ${elapsed%.*} % 60 ))s"
    elif (( elapsed >= 2 )); then
      _sc_last_duration="$(printf '%.1fs' "$elapsed")"
    fi
  fi
  _sc_cmd_start=0

  local muted="${SC_COLOR[muted]}" line1="" seg
  line1+="%F{${SC_COLOR[surface]}}╭─%f "
  [[ -n "$SSH_CONNECTION" ]] && line1+="%F{${SC_COLOR[orange]}}${SC_ICON[ssh]} %n@%m%f "
  line1+="$(_sc_dir_segment)"
  seg="$(_sc_git_segment)" && [[ -n "$seg" ]] && line1+="  $seg"
  if [[ -n "$_SC_PROJECT_TYPE" ]]; then
    line1+="  %F{${SC_COLOR[blue]}}${SC_ICON[$_SC_PROJECT_TYPE]:-$_SC_PROJECT_TYPE} ${_SC_PROJECT_TYPE}%f"
  fi
  [[ -n "$_SC_ENV_LOADED" ]] && line1+="  %F{${SC_COLOR[yellow]}}.env%f"
  [[ -n "$VIRTUAL_ENV" ]] && line1+="  %F{${SC_COLOR[yellow]}}(${VIRTUAL_ENV:t})%f"

  local right=""
  [[ -n "$_sc_last_duration" ]] && right+="%F{${SC_COLOR[yellow]}}${SC_ICON[clock]} ${_sc_last_duration}%f "
  (( _sc_last_status != 0 )) && right+="%F{${SC_COLOR[red]}}${SC_ICON[err]} ${_sc_last_status}%f "
  right+="%F{$muted}%D{%H:%M}%f"

  local arrow_color="${SC_COLOR[green]}"
  (( _sc_last_status != 0 )) && arrow_color="${SC_COLOR[red]}"

  # Bos satir + ust satir; sag taraf ayni satira hizalanir
  local zero='%([BSUbfksu]|([FK]|){*})'
  local left_len=${#${(S%%)line1//$~zero/}}
  local right_len=${#${(S%%)right//$~zero/}}
  local pad=$(( COLUMNS - left_len - right_len ))
  (( pad < 1 )) && right="" pad=0
  PROMPT=$'\n'"${line1}${(l:pad:: :)}${right}"$'\n'"%F{${SC_COLOR[surface]}}╰─%f%F{${arrow_color}}%B❯%b%f "
  RPROMPT=""
  PROMPT2="%F{${SC_COLOR[muted]}}  … %f"
}

setopt PROMPT_PERCENT NO_PROMPT_SUBST
add-zsh-hook preexec _sc_prompt_preexec
add-zsh-hook precmd _sc_prompt_precmd
