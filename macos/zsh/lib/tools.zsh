# W11 paritesi: ssh yoneticisi, tema paylas/yukle, para, ip, ascii

# ── sc ssh: baglanti yoneticisi (~/.ssh/config + ~/.systemcmd/ssh.json) ──────
typeset -g SYSTEMCMD_SSH_JSON="$HOME/.systemcmd/ssh.json"

_sc_ssh_hosts() {
  # ~/.ssh/config Host girdileri
  local cfg="$HOME/.ssh/config"
  [[ -r "$cfg" ]] && awk '
    tolower($1)=="host" {
      for(i=2;i<=NF;i++) if($i !~ /[*?]/) print "cfg\t" $i "\t~/.ssh/config"
    }' "$cfg"
  # systemcmd ssh.json (name/user/host/port)
  if [[ -r "$SYSTEMCMD_SSH_JSON" ]] && command -v python3 >/dev/null; then
    python3 - "$SYSTEMCMD_SSH_JSON" <<'PY' 2>/dev/null
import json,sys
try: a=json.load(open(sys.argv[1]))
except Exception: a=[]
for c in a:
    tgt=f"{c.get('user','')}@{c.get('host','')}".strip('@')
    port=c.get('port',22)
    print(f"scmd\t{c.get('name',tgt)}\t{tgt}:{port}")
PY
  fi
}

sc_ssh() {
  case "${1:-}" in
    add)
      command -v python3 >/dev/null || { print 'python3 gerekli.'; return 1; }
      local name user host port key
      read "name?Baglanti adi: "
      read "user?Kullanici: "
      read "host?Sunucu (host/ip): "
      read "port?Port [22]: "; port="${port:-22}"
      read "key?Anahtar yolu (bos=varsayilan): "
      [[ -d "$HOME/.systemcmd" ]] || mkdir -p "$HOME/.systemcmd"
      python3 - "$SYSTEMCMD_SSH_JSON" "$name" "$user" "$host" "$port" "$key" <<'PY'
import json,sys
f,name,user,host,port,key=sys.argv[1:7]
try: a=json.load(open(f))
except Exception: a=[]
a=[c for c in a if c.get('name')!=name]
a.append({'name':name,'user':user,'host':host,'port':int(port or 22),**({'key':key} if key else {})})
json.dump(a,open(f,'w'),indent=2,ensure_ascii=False)
print(f'  eklendi: {name}')
PY
      ;;
    rm|remove)
      command -v python3 >/dev/null || return 1
      python3 - "$SYSTEMCMD_SSH_JSON" "$2" <<'PY' 2>/dev/null
import json,sys
f,name=sys.argv[1],sys.argv[2]
try: a=json.load(open(f))
except Exception: a=[]
json.dump([c for c in a if c.get('name')!=name],open(f,'w'),indent=2,ensure_ascii=False)
print(f'  silindi: {name}')
PY
      ;;
    *)
      command -v fzf >/dev/null || { print 'fzf gerekli. sc ssh add ile baglanti ekle.'; return 1; }
      local sel host
      sel="$(_sc_ssh_hosts | awk '!s[$2]++' |
        fzf --ansi --delimiter='\t' --with-nth=2,3 --prompt='ssh > ' \
          --border-label=' systemcmd ssh ' \
          --header='Enter: baglan · sc ssh add: yeni · sc ssh rm <ad>: sil' \
          --preview='echo "{}" | cut -f3')" || return
      [[ -n "$sel" ]] || return
      local kind="${sel%%$'\t'*}" name="${${sel#*$'\t'}%%$'\t'*}"
      if [[ "$kind" == scmd ]]; then
        # ssh.json'dan tam komutu kur
        local line; line="$(python3 - "$SYSTEMCMD_SSH_JSON" "$name" <<'PY'
import json,sys
a=json.load(open(sys.argv[1]))
for c in a:
  if c.get('name')==sys.argv[2]:
    t=f"{c.get('user','')}@{c.get('host','')}".strip('@')
    print(f"-p {c.get('port',22)}"+(f" -i {c['key']}" if c.get('key') else "")+f" {t}")
PY
)"
        print -P "%F{${SC_COLOR[cyan]}}baglaniyor:%f ssh $line"
        eval "ssh $line"
      else
        print -P "%F{${SC_COLOR[cyan]}}baglaniyor:%f ssh $name"
        ssh "$name"
      fi
      ;;
  esac
}

# ── sc theme share / install: tasinabilir tema kodu (SCMD1: gzip+base64url) ──
sc_theme_share() {
  command -v python3 >/dev/null || { print 'python3 gerekli.'; return 1; }
  local json="{\"name\":\"${SYSTEMCMD_THEME_NAME}\",\"palette\":{"
  local k first=1
  for k in "${(@k)SC_COLOR}"; do
    (( first )) || json+=","; first=0
    json+="\"$k\":\"${SC_COLOR[$k]}\""
  done
  json+="}}"
  local code
  code="$(print -r -- "$json" | python3 -c '
import sys,gzip,base64
raw=sys.stdin.buffer.read()
gz=gzip.compress(raw,9)
print("SCMD1:"+base64.b64encode(gz).decode().replace("+","-").replace("/","_").rstrip("="))')"
  print -P "\n  %F{${SC_COLOR[muted]}}Temayi paylasmak icin bu kodu gonder:%f\n"
  print -P "  %F{${SC_COLOR[cyan]}}$code%f\n"
  command -v pbcopy >/dev/null && print -r -- "$code" | pbcopy && print -P "  %F{${SC_COLOR[green]}}(panoya kopyalandi)%f\n"
}

sc_theme_install() {
  local code="$1"
  [[ "$code" == SCMD1:* ]] || { print 'Gecersiz tema kodu (SCMD1: oneki yok).'; return 1; }
  command -v python3 >/dev/null || { print 'python3 gerekli.'; return 1; }
  local out
  out="$(print -r -- "$code" | python3 -c '
import sys,gzip,base64,json
c=sys.stdin.read().strip()[6:]
c=c.replace("-","+").replace("_","/"); c+="="*(-len(c)%4)
d=json.loads(gzip.decompress(base64.b64decode(c)))
pal=d.get("palette",{})
name="".join(ch for ch in d.get("name","paylasilan") if ch.isalnum() or ch in "-_") or "paylasilan"
print(name)
for k,v in pal.items(): print(f"{k}\t{v}")')" || { print 'Kod cozulemedi.'; return 1; }
  local name="${out%%$'\n'*}"
  # Yerlesik temalarin uzerine yazma — cakisirsa -paylasilan eki
  case "$name" in
    systemcmd|neon|matrix|sunset) name="${name}-paylasilan" ;;
  esac
  local file="$SYSTEMCMD_ROOT/themes/$name.zsh"
  { print -r -- "# Paylasilan tema: $name"
    print -rn -- "SC_COLOR=("
    print -r -- "$out" | tail -n +2 | while IFS=$'\t' read -r k v; do printf '%s %q ' "$k" "$v"; done
    print -r -- ")"
  } > "$file"
  print -P "  %F{${SC_COLOR[green]}}tema yuklendi:%f $name  —  %F{${SC_COLOR[muted]}}sc theme $name ile gec%f"
}

# ── para: doviz cevirisi (USD/EUR -> TRY) ───────────────────────────────────
para() {
  local amt="${1:-1}"
  command -v python3 >/dev/null || { print 'python3 gerekli.'; return 1; }
  print -P "  %F{${SC_COLOR[muted]}}kurlar aliniyor...%f"
  local data; data="$(curl -fsS --max-time 8 'https://api.exchangerate-api.com/v4/latest/USD' 2>/dev/null)"
  [[ -n "$data" ]] || { print '  Kur alinamadi (internet?).'; return 1; }
  print -r -- "$data" | python3 -c '
import sys,json
try:
    d=json.load(sys.stdin); amt=float(sys.argv[1]); r=d["rates"]
    try_usd=r["TRY"]; eur_usd=r["EUR"]
    usd=amt*try_usd; eur=amt*(try_usd/eur_usd)
    G="\033[38;5;85m"; C="\033[38;5;117m"; M="\033[38;5;245m"; R="\033[0m"
    print(f"\n  {C}{amt:g} USD{R} {M}={R} {G}{usd:,.2f} TL{R}".replace("TL","₺"))
    print(f"  {C}{amt:g} EUR{R} {M}={R} {G}{eur:,.2f} ₺{R}")
    print(f"  {M}1 USD = {try_usd:.4f} ₺  1 EUR = {try_usd/eur_usd:.4f} ₺{R}\n")
except Exception:
    print("  Kur cozulemedi.")
' "$amt"
}

# ── ip: ag bilgisi (LAN tum arayuzler + WAN + gateway) ──────────────────────
ip() {
  local m="${SC_COLOR[muted]}" f="${SC_COLOR[fg]}" g="${SC_COLOR[green]}"
  print -P "\n  %B%F{${SC_COLOR[cyan]}}Ag%f%b"
  local i ipx
  for i in $(ifconfig -lu 2>/dev/null); do
    [[ "$i" == lo* ]] && continue
    ipx="$(ipconfig getifaddr "$i" 2>/dev/null)"
    [[ -n "$ipx" ]] && print -P "  %F{$m}${(r:8:)i}%f %F{$g}$ipx%f"
  done
  local gw="$(route -n get default 2>/dev/null | awk '/gateway/{print $2}')"
  local dev="$(route -n get default 2>/dev/null | awk '/interface/{print $2}')"
  [[ -n "$gw" ]] && print -P "  %F{$m}gateway %f%F{$f}$gw%f %F{$m}(${dev})%f"
  local wan="$(curl -fsS --max-time 4 https://ifconfig.me 2>/dev/null)"
  print -P "  %F{$m}WAN     %f%F{$g}${wan:-yok}%f"
  # Wi-Fi SSID (varsa)
  local ssid="$(ipconfig getsummary en0 2>/dev/null | awk -F' SSID : ' '/ SSID :/{print $2; exit}')"
  [[ -n "$ssid" ]] && print -P "  %F{$m}Wi-Fi   %f%F{$f}$ssid%f"
  print
}

# ── ascii <metin>: buyuk ascii yazi (figlet varsa) ──────────────────────────
ascii() {
  local text="$*"
  [[ -n "$text" ]] || { print 'Kullanim: ascii <metin>'; return 1; }
  if command -v figlet >/dev/null; then
    figlet -- "$text"
  else
    print -P "  %F{${SC_COLOR[muted]}}figlet yok:%f brew install figlet"
    print -P "  %F{${SC_COLOR[cyan]}}$text%f"
  fi
}
