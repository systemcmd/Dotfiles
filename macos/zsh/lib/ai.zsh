# AI: terminalden Claude'a sor (claude CLI ile, ek API anahtari gerekmez)
#
#   ?? 3000 portunu kim kullaniyor   -> komutu satira yazar, Enter ile calistirirsin
#   sc ask <soru>                    -> serbest soru, Turkce cevap
#   sc explain <komut> / Alt+E       -> satirdaki komutu aciklar
#   fix                              -> son hatali komut icin duzeltme onerir
#
# Bilinmeyen komutta yazim hatasi onerisi (gti -> git) AI olmadan, aninda calisir.

typeset -g SYSTEMCMD_AI_MODEL="${SYSTEMCMD_AI_MODEL:-haiku}"
typeset -g _SC_LAST_TYPO_FILE="$SYSTEMCMD_HOME/last-typo"

_sc_ai_call() {
  local system="$1" prompt="$2" label="${3:-dusunuyor}"
  if ! command -v claude >/dev/null; then
    print -P "%F{${SC_COLOR[red]}}claude CLI bulunamadi.%f Kurulum: https://claude.com/claude-code" >&2
    return 127
  fi
  setopt local_options local_traps no_monitor no_notify
  local tmp="$(mktemp -t systemcmd-ai)"
  claude -p --model "$SYSTEMCMD_AI_MODEL" --tools "" --no-session-persistence --strict-mcp-config \
    --system-prompt "$system" "$prompt" >| "$tmp" 2>&1 &
  local pid=$! i=0 frames='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏' rgb="$(_sc_hex2rgb "${SC_COLOR[cyan]}")"
  trap "kill $pid 2>/dev/null; rm -f ${(q)tmp}; printf '\r\e[K' >&2; return 130" INT
  while kill -0 $pid 2>/dev/null; do
    printf '\r\e[38;2;%sm%s\e[0m %s ' "$rgb" "${frames[i % 10 + 1]}" "$label" >&2
    (( i++ ))
    sleep 0.08
  done
  wait $pid
  local rc=$?
  printf '\r\e[K' >&2
  REPLY="$(<"$tmp")"
  rm -f "$tmp"
  return $rc
}

_sc_ai_context() {
  print -r -- "OS: macOS $(sw_vers -productVersion 2>/dev/null), shell: zsh, cwd: $PWD${_SC_PROJECT_TYPE:+, proje turu: $_SC_PROJECT_TYPE}"
}

# Dogal dil -> tek komut, satira yazilir (asla otomatik calismaz)
sc_ai_cmd() {
  local q="$*"
  [[ -z "$q" ]] && { print 'Kullanim: ?? <ne yapmak istiyorsun>'; return 1; }
  _sc_ai_call "You turn a request (often in Turkish) into ONE shell command for macOS zsh. $(_sc_ai_context). Output ONLY the command on a single line. No markdown, no backticks, no explanation. Prefer the safest, non-destructive variant." \
    "$q" "komut hazirlaniyor" || { print -r -- "$REPLY"; return 1; }
  local cmd="${${REPLY//\`/}##[[:space:]]#}"
  cmd="${cmd%%$'\n'*}"
  print -P "%F{${SC_COLOR[muted]}}Enter: calistir | duzenle | Ctrl+C: vazgec%f"
  print -z -- "$cmd"
}
alias '??'='noglob sc_ai_cmd'

sc_ai_ask() {
  local q="$*"
  [[ -z "$q" ]] && { print 'Kullanim: sc ask <soru>'; return 1; }
  _sc_ai_call "Kisa ve net Turkce cevap ver. Terminalde okunacak: markdown baslik kullanma, en fazla 12 satir. $(_sc_ai_context)" "$q" "soruluyor" || { print -r -- "$REPLY"; return 1; }
  if command -v bat >/dev/null; then print -r -- "$REPLY" | bat --language=markdown --style=plain --color=always --paging=never
  else print -r -- "$REPLY"; fi
}

sc_ai_explain() {
  local c="$*"
  [[ -z "$c" ]] && { print 'Kullanim: sc explain <komut>'; return 1; }
  _sc_ai_call "Verilen shell komutunu Turkce acikla: once tek cumlelik ozet, sonra her parca/bayrak icin kisa madde. Riskli bir sey varsa 'DIKKAT:' ile belirt. Markdown baslik yok, en fazla 10 satir." "$c" "aciklaniyor" || { print -r -- "$REPLY"; return 1; }
  print -r -- "$REPLY"
}

# Alt+E: satirdaki komutu aciklar, satir korunur
sc-explain-widget() {
  [[ -z "$BUFFER" ]] && { zle -M 'Aciklanacak komut yok.'; return; }
  local buf="$BUFFER"
  zle -I
  print
  sc_ai_explain "$buf"
  zle reset-prompt
}
zle -N sc-explain-widget
bindkey '^[e' sc-explain-widget

# Son komut hata verdiyse duzeltme onerisi: once yazim hatasi, sonra AI
sc_fix() {
  local last="${history[$((HISTCMD-1))]}"
  [[ "$last" == fix || "$last" == 'sc fix' ]] && last="${history[$((HISTCMD-2))]}"
  [[ -z "$last" ]] && { print 'Duzeltilecek komut yok.'; return 1; }
  # Son komut bilinmeyen komut hatasiysa yazim onerisini kullan (AI'siz, aninda)
  if [[ -r "$_SC_LAST_TYPO_FILE" ]]; then
    local typo="$(<"$_SC_LAST_TYPO_FILE")"
    rm -f "$_SC_LAST_TYPO_FILE"
    if [[ -n "$typo" && "${last%% *}" == "${typo%%$'\t'*}" ]]; then
      print -z -- "${typo#*$'\t'}"
      return
    fi
  fi
  _sc_ai_call "The user's last macOS zsh command failed (exit code ${_sc_last_status:-?}). $(_sc_ai_context). Reply with ONLY the corrected single-line command. No markdown, no explanation." \
    "$last" "duzeltme araniyor" || { print -r -- "$REPLY"; return 1; }
  local cmd="${${REPLY//\`/}%%$'\n'*}"
  print -P "%F{${SC_COLOR[muted]}}Oneri (Enter ile calistir):%f"
  print -z -- "$cmd"
}
alias fix='sc_fix'

# Bilinmeyen komut: benzer komutlari oner, 'fix' ile duzelt
command_not_found_handler() {
  local cmd="$1"; shift
  local -a near
  near=(${(k)commands[(I)(#a1)$cmd]} ${(k)aliases[(I)(#a1)$cmd]} ${(k)functions[(I)(#a1)$cmd]})
  near=(${(u)near:#_*})
  print -P "%F{${SC_COLOR[red]}}komut bulunamadi:%f $cmd" >&2
  if (( ${#near} )); then
    local best="${near[1]}"
    print -P "%F{${SC_COLOR[muted]}}  bunu mu demek istedin?%f %F{${SC_COLOR[green]}}${(j:, :)near[1,4]}%f  %F{${SC_COLOR[muted]}}-> 'fix' yaz%f" >&2
    print -r -- "$cmd"$'\t'"$best${*:+ ${(q-)@}}" >| "$_SC_LAST_TYPO_FILE"
  else
    : >| "$_SC_LAST_TYPO_FILE"
    print -P "%F{${SC_COLOR[muted]}}  kurmak icin: brew install $cmd  |  AI'a sor: ?? $cmd%f" >&2
  fi
  return 127
}
