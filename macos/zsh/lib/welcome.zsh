# Karsilama ekrani: hizli (<100ms), harici agir komut yok
# Kapatmak icin: export SYSTEMCMD_WELCOME=0

_sc_gradient() {
  # $1 metin, $2 $3 baslangic/bitis renk (hex)
  local text="$1" a="${2#\#}" b="${3#\#}" n=${#1} i out=""
  local r1=$((16#${a[1,2]})) g1=$((16#${a[3,4]})) b1=$((16#${a[5,6]}))
  local r2=$((16#${b[1,2]})) g2=$((16#${b[3,4]})) b2=$((16#${b[5,6]}))
  for (( i = 1; i <= n; i++ )); do
    local t=$(( n > 1 ? (i - 1) * 1000 / (n - 1) : 0 ))
    out+=$'\e[38;2;'"$(( r1 + (r2 - r1) * t / 1000 ));$(( g1 + (g2 - g1) * t / 1000 ));$(( b1 + (b2 - b1) * t / 1000 ))m${text[i]}"
  done
  print -r -- "${out}"$'\e[0m'
}

sc_welcome() {
  local c1="${SC_COLOR[cyan]}" c2="${SC_COLOR[magenta]}"
  local -a logo=(
    '  ┌─┐┬ ┬┌─┐┌┬┐┌─┐┌┬┐┌─┐┌┬┐┌┬┐'
    '  └─┐└┬┘└─┐ │ ├┤ │││├─┘│││ ││'
    '  └─┘ ┴ └─┘ ┴ └─┘┴ ┴┴  ┴ ┴─┴┘'
  )
  local l
  print
  for l in "${logo[@]}"; do _sc_gradient "$l" "$c1" "$c2"; done

  # Yavas olanlar (pmset ~180ms) onbellekten okunur, arka planda tazelenir
  local cache="$SYSTEMCMD_HOME/welcome-cache" batt="" disk="" ip="" load up
  [[ -r "$cache" ]] && IFS='|' read -r batt disk ip < "$cache"
  ( {
      print -r -- "$(pmset -g batt 2>/dev/null | grep -Eo '[0-9]+%' | head -1)|$(df -h / 2>/dev/null | awk 'NR==2 {print $4 " bos"}')|$(ipconfig getifaddr en0 2>/dev/null)"
    } >| "$cache.tmp" && mv -f "$cache.tmp" "$cache" ) &>/dev/null &!

  local -a sys=("${(@f)$(sysctl -n vm.loadavg kern.boottime 2>/dev/null)}")
  load="${${(z)sys[1]}[2]}"
  local boot="${${sys[2]#*sec = }%%,*}"
  if [[ "$boot" == <-> ]]; then
    local s=$(( EPOCHSECONDS - boot ))
    up="$(( s % 86400 / 3600 ))sa $(( s % 3600 / 60 ))dk"
    (( s >= 86400 )) && up="$(( s / 86400 ))g $up"
  fi

  local m="${SC_COLOR[muted]}" f="${SC_COLOR[fg]}"
  batt="${batt//\%/%%}" disk="${disk//\%/%%}"
  print -P "  %F{$m}$(strftime '%d %b %a %H:%M' $EPOCHSECONDS) · %F{$f}%n@%m%F{$m} · yuk %F{$f}${load:-?}%F{$m} · acik %F{$f}${up:-?}%f"
  print -P "  %F{$m}disk %F{$f}${disk:-?}%F{$m} · pil %F{$f}${batt:-AC}%F{$m} · ip %F{$f}${ip:-yok}%F{$m} · tema %F{$f}$SYSTEMCMD_THEME_NAME%f"

  local -a tips=(
    "Ctrl+R'de f'ye bas: komut favori olur, hep ustte kalir"
    "?? ile Turkce sor: ?? buyuk dosyalari bul"
    "Ctrl+G: degisen dosyalar, branch'ler, commit'ler tek yerde"
    "Ctrl+P: projeler arasinda isinlan"
    "sc run: projeye gore hazir komutlar (flutter run, pub get...)"
    "Alt+E: satirdaki komutu calistirmadan once acikla"
    "fix: son hatali komutu duzeltir"
    "sc theme neon / matrix / sunset"
    "Alt+Space: Ghostty her yerden acilir"
    "sc layout: editor + shell + git tek ekranda"
  )
  print -P "  %F{${SC_COLOR[yellow]}}ipucu%f %F{$m}${tips[RANDOM % ${#tips} + 1]}  ·  sc keys%f"
}

if [[ "${SYSTEMCMD_WELCOME:-1}" == 1 && -z "$_SC_WELCOMED" && -z "$ZELLIJ" && -z "$TMUX" ]]; then
  export _SC_WELCOMED=1
  sc_welcome
fi
