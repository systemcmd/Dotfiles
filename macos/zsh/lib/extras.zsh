# W11 paritesi: dashboard, tips, wrapped, config, cloudhelp (macOS native)

# ── Ilerleme cubugu ──────────────────────────────────────────────────────────
_sc_bar() { # $1 yuzde 0-100, $2 genislik, $3 renk
  local pct=$1 w=${2:-24} col=${3:-${SC_COLOR[green]}} fill
  (( pct < 0 )) && pct=0; (( pct > 100 )) && pct=100
  fill=$(( pct * w / 100 ))
  printf '\e[38;2;%sm%s\e[38;5;236m%s\e[0m \e[38;5;245m%d%%\e[0m' \
    "$(_sc_hex2rgb "$col")" "${(l:fill::█:)}" "${(l:$((w-fill))::░:)}" "$pct"
}

# ── sc dashboard: canli sistem panosu (q ile cik) ───────────────────────────
sc_dashboard() {
  local refresh="${SYSTEMCMD_DASH_REFRESH:-2}"
  printf '\e[?25l'            # imleci gizle
  trap 'printf "\e[?25h\e[0m"; return 0' INT
  local cpu mem_pct disk_pct key
  while true; do
    sc_sys_collect
    # Anlik CPU: tum islemlerin %cpu toplami / cekirdek (cok cekirdekte 100'u asabilir -> kirp)
    cpu="$(ps -A -o %cpu= 2>/dev/null | awk -v n="${SC_SYS[ncpu]:-1}" '{s+=$1} END{v=s/n; if(v>100)v=100; printf "%d", v}')"
    mem_pct=$(( SC_SYS[mem_used] * 100 / SC_SYS[mem_total] ))
    disk_pct=$(( 100 - SC_SYS[disk_free] * 100 / SC_SYS[disk_total] ))
    local bcol="${SC_COLOR[green]}"; [[ "${SC_SYS[batt_state]}" == discharging ]] && (( SC_SYS[batt] <= 20 )) && bcol="${SC_COLOR[red]}"

    printf '\e[H\e[2J'
    print -P "  %B%F{${SC_COLOR[magenta]}}  systemcmd dashboard  %f%b  %F{${SC_COLOR[muted]}}$(strftime '%H:%M:%S' $EPOCHSECONDS) · q ile cik%f\n"
    printf '  \e[38;5;214m⚡ CPU  \e[0m %s  \e[38;5;245m%s cekirdek · yuk %s\e[0m\n' "$(_sc_bar ${cpu%.*} 28 ${SC_COLOR[orange]})" "${SC_SYS[ncpu]}" "${SC_SYS[load]}"
    printf '  \e[38;5;141m🧠 RAM  \e[0m %s  \e[38;5;245m%s/%s GB\e[0m\n' "$(_sc_bar $mem_pct 28 ${SC_COLOR[purple]})" "$(_sc_gib ${SC_SYS[mem_used]})" "$(_sc_gib ${SC_SYS[mem_total]})"
    printf '  \e[38;5;45m💾 DISK \e[0m %s  \e[38;5;245m%s GB bos / %s GB\e[0m\n' "$(_sc_bar $disk_pct 28 ${SC_COLOR[cyan]})" "$(_sc_gb ${SC_SYS[disk_free]})" "$(_sc_gb ${SC_SYS[disk_total]})"
    if [[ -n "${SC_SYS[batt]}" ]]; then
      printf '  \e[38;5;220m🔋 PIL  \e[0m %s  \e[38;5;245m%s\e[0m\n' "$(_sc_bar ${SC_SYS[batt]} 28 $bcol)" "$(sc_sys_batt_text)"
    fi
    printf '  \e[38;5;117m🌐 AG   \e[0m \e[38;5;245m%s%s · %s\e[0m\n' "${SC_SYS[ip]:-yok}" "${SC_SYS[vpn]:+ (VPN)}" "${SC_SYS[iface]}"
    print
    print -P "  %F{${SC_COLOR[muted]}}En cok CPU kullanan islemler%f"
    ps -Aceo pcpu,rss,comm -r 2>/dev/null | awk 'NR>1 && NR<=6 {name=$3; for(i=4;i<=NF;i++)name=name" "$i; printf "    \033[38;5;117m%5.1f%%\033[0m \033[38;5;245m%5d MB\033[0m  %s\n",$1,$2/1024,name}'

    read -t "$refresh" -k 1 key 2>/dev/null && [[ "$key" == q ]] && break
  done
  printf '\e[?25h\e[0m'
  trap - INT
}

# ── sc tips / sc tip: ipucu galerisi ────────────────────────────────────────
typeset -ga SC_TIPS=(
  "Ctrl+R: gecmiste ara. f (arama bosken) veya Ctrl+S ile komutu favoriye ekle/cikar — favoriler hep ustte."
  "Ctrl+F: baglamsal dosya secici. Once bir klasor yolu yaz, sonra Ctrl+F o dizini listeler."
  "Ctrl+G: degisen dosyalar, Ctrl+B branch, Ctrl+L commit, Ctrl+T stash — hepsi tek pencerede."
  "Ctrl+P: Desktop/Developer/Projects altindaki git depolari arasinda isinlan."
  "gco: fzf ile interaktif branch checkout, secili dalin son commitlerini onizler."
  "glog: commit gecmisini gorsel gez, Enter ile secili commiti delta ile goster."
  "gstash: stash listeni yonet — Enter apply, Ctrl+P pop, Ctrl+D drop."
  "gwip: tum degisiklikleri 'wip: tarih' commitine al; gunwip ile soft reset'le geri al."
  "gst: kisa, renkli git durumu. gbd: fzf ile coklu branch sil (Tab)."
  "sc sys: pil sagligi, dongu, RAM, disk, ag — macOS'un kendi degerleriyle."
  "sc dashboard: CPU/RAM/disk/pil/ag canli izle (q ile cik)."
  "sc wrapped: en cok kullandigin araclar, cesitlilik skoru ve yazim hatasi adaylari."
  "sc run: klasordeki projeyi algila, hazir komutlari menuden sec (flutter/npm/cargo/go...)."
  "sc env: .env dosyasini guvenle yukle (kod calistirmaz); sc env off ile kaldir."
  "?? <istek>: Turkce yaz, komutu satira getirir. Enter'a sen basarsin."
  "fix: son hatali/yazim hatasi komutu duzeltir. Alt+E: satirdaki komutu AI ile acikla."
  "sc theme: systemcmd / neon / matrix / sunset. Ghostty renkleri de aninda degisir."
  "buddy: companion karti. buddy hatch ile yumurtayi kir, buddyxp ile seviye, bp ile guc."
  "which <komut>: komutun gercek yolunu ve turunu goster. rmrf: hizli zorla sil (dikkat)."
  "z <parca>: zoxide ile akilli cd. zi: interaktif secim. ll/la/lt: eza ile listeler."
  "Alt+Space: Ghostty'yi her yerden asagi indir (quick terminal)."
  "sc layout: zellij ile editor + shell + lazygit tek ekranda."
  "Ctrl+X Ctrl+E: uzun komutu nvim'de duzenle, kaydedince calisir."
  "cloudhelp: Claude Code komutlarina Turkce referans."
)

sc_tip()  { print; print -P "  %F{${SC_COLOR[yellow]}}ipucu%f  ${SC_TIPS[RANDOM % ${#SC_TIPS} + 1]}"; print; }
sc_tips() {
  if command -v fzf >/dev/null; then
    print -rl -- "${SC_TIPS[@]}" | fzf --ansi --no-sort --prompt='ipucu > ' \
      --border-label=' systemcmd ipuclari ' --height=80% --wrap 2>/dev/null \
      --preview='printf "%s" {}' --preview-window='down,4,wrap,border-top' >/dev/null
  else
    local t i=1
    print
    for t in "${SC_TIPS[@]}"; do print -P "  %F{${SC_COLOR[muted]}}$(printf '%02d' $i)%f  $t"; (( i++ )); done
    print
  fi
}

# ── sc wrapped: kisisel shell raporu ────────────────────────────────────────
sc_wrapped() {
  local hist="${HISTFILE:-$HOME/.zsh_history}"
  [[ -r "$hist" ]] || { print 'Gecmis dosyasi yok.'; return 1; }
  local m="${SC_COLOR[muted]}" f="${SC_COLOR[fg]}"
  print -P "\n  %B%F{${SC_COLOR[purple]}}✦ SYSTEMCMD WRAPPED%f%b  %F{$m}kisisel shell raporun%f"
  print -P "  %F{238}$(printf '─%.0s' {1..52})%f\n"
  # Komut satirlarini al (zsh extended history: ': ts:0;cmd')
  local -a cmds
  cmds=("${(@f)$(sed -E 's/^: [0-9]+:[0-9]+;//' "$hist" 2>/dev/null | sed -E 's/^[[:space:]]+//' | grep -v '^$')}")
  local total=${#cmds}
  (( total )) || { print '  Gecmis bos.'; return 0; }
  # Kok komut frekansi
  local -A freq
  local c root
  for c in "${cmds[@]}"; do
    root="${${(z)c}[1]}"
    [[ "$root" == [A-Za-z_./-]* ]] || continue   # ozel karakterli subscript'i atla
    (( freq[$root]++ ))
  done
  local uniq=${#freq}
  local div=$(( uniq * 100 / total )); (( div > 100 )) && div=100
  local cy="$(_sc_hex2rgb ${SC_COLOR[cyan]})" or="$(_sc_hex2rgb ${SC_COLOR[orange]})" mu="$(_sc_hex2rgb $m)"
  printf "  \e[38;2;%sm%s\e[0m \e[38;2;%smtoplam komut · \e[38;2;%sm%d\e[38;2;%sm farkli arac · cesitlilik \e[38;2;%sm%%%d\e[0m\n\n" \
    "$cy" "$(printf "%'d" $total)" "$mu" "$cy" "$uniq" "$mu" "$or" "$div"
  printf "  \e[38;2;%sm★ En cok kullandigin araclar\e[0m\n" "$or"
  local -a top; top=("${(@f)$(for k in "${(@k)freq}"; do print -r -- "${freq[$k]} $k"; done | sort -rn | head -8)}")
  local maxv="${${(z)top[1]}[1]}" rank=1
  local -a medal=('①' '②' '③' '④' '⑤' '⑥' '⑦' '⑧')
  for line in "${top[@]}"; do
    local v="${${(z)line}[1]}" name="${${(z)line}[2]}"
    printf "    \e[38;2;%sm%s\e[0m \e[38;2;%sm%-14s\e[0m %s \e[38;2;%sm%dx\e[0m\n" \
      "$mu" "${medal[rank]}" "$cy" "$name" "$(_sc_bar $(( v * 100 / maxv )) 20 ${SC_COLOR[green]})" "$mu" "$v"
    (( rank++ ))
  done
  # En aktif saat
  local busy="$(sed -nE 's/^: ([0-9]+):[0-9]+;.*/\1/p' "$hist" 2>/dev/null | while read -r t; do strftime '%H' $t; done | sort | uniq -c | sort -rn | head -1)"
  [[ -n "$busy" ]] && print -P "\n  %F{$m}En aktif saat:%f %F{$f}${${(z)busy}[2]}:00%f %F{$m}(${${(z)busy}[1]} komut)%f"
  print
}

# ── sc config: ortak ~/.systemcmd/config.json (W11 ile paylasimli) ──────────
typeset -g SYSTEMCMD_CONFIG="$HOME/.systemcmd/config.json"
_sc_cfg_py() { command -v python3 >/dev/null && python3 "$@"; }

sc_config() {
  [[ -d "$HOME/.systemcmd" ]] || mkdir -p "$HOME/.systemcmd"
  case "${1:-show}" in
    show)
      if [[ -r "$SYSTEMCMD_CONFIG" ]]; then
        if command -v bat >/dev/null; then bat --language=json --style=plain --paging=never "$SYSTEMCMD_CONFIG"
        else cat "$SYSTEMCMD_CONFIG"; fi
      else print -P "  %F{${SC_COLOR[muted]}}Henuz config yok. 'sc config set <anahtar> <deger>' ile olustur.%f"; fi ;;
    get) _sc_cfg_get "$2" ;;
    set) _sc_cfg_set "$2" "$3" ;;
    *) print 'Kullanim: sc config [show | get <anahtar> | set <anahtar> <deger>]' ;;
  esac
}
_sc_cfg_get() {
  _sc_cfg_py - "$SYSTEMCMD_CONFIG" "$1" <<'PY'
import json,sys
try: d=json.load(open(sys.argv[1]))
except Exception: d={}
for p in sys.argv[2].split('.'):
    d=d.get(p,{}) if isinstance(d,dict) else {}
print('' if d=={} else (json.dumps(d) if isinstance(d,(dict,list)) else d))
PY
}
_sc_cfg_set() {
  [[ -n "$1" ]] || { print 'Kullanim: sc config set <anahtar> <deger>'; return 1; }
  _sc_cfg_py - "$SYSTEMCMD_CONFIG" "$1" "$2" <<'PY'
import json,sys
f,key,val=sys.argv[1],sys.argv[2],sys.argv[3]
try: d=json.load(open(f))
except Exception: d={}
# tip cevirisi
if val.lower() in ('true','false'): val=val.lower()=='true'
elif val.lstrip('-').isdigit(): val=int(val)
node=d; parts=key.split('.')
for p in parts[:-1]: node=node.setdefault(p,{})
node[parts[-1]]=val
json.dump(d,open(f,'w'),indent=2,ensure_ascii=False)
print(f'  {key} = {val}')
PY
}

# ── cloudhelp: Claude Code TR referansi ─────────────────────────────────────
cloudhelp() {
  local m="${SC_COLOR[muted]}" g="${SC_COLOR[green]}" c="${SC_COLOR[cyan]}"
  local -a rows=(
    "claude|Interaktif Claude Code oturumu baslat"
    "claude -p '<soru>'|Tek seferlik soru, cevabi yazdirir (print mode)"
    "claude -c|Son oturuma devam et (continue)"
    "claude --model opus|Modeli sec (opus/sonnet/haiku)"
    "claude commit|Degisiklikleri inceleyip commit mesaji yaz"
    "/clear|Oturum baglamini temizle"
    "/undo|Son degisikligi geri al"
    "/review|Mevcut diff'i incele"
    "/model|Oturum icinde model degistir"
    "# <not>|Memory'ye kalici not ekle"
    "?? <istek>|(systemcmd) Turkce'den komut uret"
    "ai <soru>|(systemcmd) Claude'a hizli soru"
  )
  print -P "\n  %B%F{$c}cloudhelp%f%b  %F{$m}Claude Code — Turkce referans%f\n"
  local r
  for r in "${rows[@]}"; do print -P "  %F{$g}${(r:22:)${r%%|*}}%f %F{$m}${r#*|}%f"; done
  print
}
