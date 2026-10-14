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

  sc_sys_collect
  local m="${SC_COLOR[muted]}" f="${SC_COLOR[fg]}"
  local batt="$(sc_sys_batt_text)" bc="$(sc_sys_batt_color)"
  local mem="$(_sc_gib ${SC_SYS[mem_used]})/$(_sc_gib ${SC_SYS[mem_total]}) GB"
  local disk="$(_sc_gb ${SC_SYS[disk_free]}) GB bos"
  local net="${SC_SYS[ip]:-baglanti yok}${SC_SYS[vpn]:+ · VPN}"
  print -P "  %F{$m}$(strftime '%d %b %a %H:%M' $EPOCHSECONDS) · %F{$f}%n@%m%F{$m} · yuk %F{$f}${SC_SYS[load]}%F{$m}/${SC_SYS[ncpu]} · acik %F{$f}${SC_SYS[uptime]:-?}%f"
  print -P "  %F{$m}pil %F{$bc}${batt//\%/%%}%F{$m} · ram %F{$f}${mem}%F{$m} · disk %F{$f}${disk}%F{$m} · ip %F{$f}${net}%f"

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
