# sc / systemcmd: komut merkezi

_sc_c() { print -n -- "%F{${SC_COLOR[$1]}}"; }

sc_keys() {
  print -P "
$(_sc_c cyan)%Bsystemcmd kisayollari%b%f

  $(_sc_c green)Ctrl+R%f   gecmis arama   $(_sc_c muted)f / Ctrl+S favori, favoriler ustte%f
  $(_sc_c green)Ctrl+F%f   dosya secici   $(_sc_c muted)klasor yazip bas: o klasorun icini acar%f
  $(_sc_c green)Ctrl+G%f   git gezgini    $(_sc_c muted)Ctrl+B branch, Ctrl+L commit, Ctrl+T stash%f
  $(_sc_c green)Ctrl+P%f   proje atla     $(_sc_c muted)Desktop/Developer/Projects altindaki repolar%f
  $(_sc_c green)Alt+E%f    komutu acikla  $(_sc_c muted)satirdaki komutu AI aciklar%f
  $(_sc_c green)Ctrl+X Ctrl+E%f  komutu nvim'de duzenle

$(_sc_c cyan)%Bkomutlar%b%f

  $(_sc_c green)?? <istek>%f       dogal dilden komut   $(_sc_c muted)?? 3000 portunu kim kullaniyor%f
  $(_sc_c green)fix%f              son hatali komutu duzelt
  $(_sc_c green)sc run%f           proje gorevleri (flutter/npm/cargo/make...)
  $(_sc_c green)sc env%f           .env yukle  $(_sc_c muted)(sc env off: kaldir)%f
  $(_sc_c green)sc ask <soru>%f    AI'a soru sor
  $(_sc_c green)sc theme [ad]%f    tema degistir  $(_sc_c muted)($(sc_theme_names | tr '\n' ' '))%f
  $(_sc_c green)sc layout%f        zellij calisma duzeni (editor + shell + git)
  $(_sc_c green)sc dashboard%f     canli sistem panosu (q ile cik)
  $(_sc_c green)sc wrapped%f       kisisel shell raporu
  $(_sc_c green)sc tips%f          ipucu galerisi  $(_sc_c muted)(sc tip: tek rastgele)%f
  $(_sc_c green)sc config%f        ayarlar (W11 ile ortak json)
  $(_sc_c green)cloudhelp%f        Claude Code TR referansi
  $(_sc_c green)sc ssh%f           SSH baglanti yoneticisi  $(_sc_c muted)(add/rm)%f
  $(_sc_c green)sc theme share%f   temayi kod olarak paylas  $(_sc_c muted)(install <kod>)%f
  $(_sc_c green)para <miktar>%f    USD/EUR -> TRY  $(_sc_c green)ip%f  ag bilgisi  $(_sc_c green)ascii%f  yazi
  $(_sc_c green)gco glog gst%f     $(_sc_c muted)gstash gwip gunwip gbd — git kisayollari%f
  $(_sc_c green)sc sys%f           pil (saglik, dongu), RAM, disk, ag
  $(_sc_c green)sc doctor%f        kurulum kontrolu
  $(_sc_c green)z <parca>%f        akilli cd (zoxide)  $(_sc_c muted)zi: interaktif%f

$(_sc_c cyan)%BBuddy%b%f  $(_sc_c muted)(companion — Windows/Mac/Linux ortak)%f

  $(_sc_c green)buddy%f            companion karti   $(_sc_c muted)buddy hatch: yumurtayi kir%f
  $(_sc_c green)buddy pet%f        onu oksa          $(_sc_c green)buddy list%f  17 pet
  $(_sc_c green)buddyxp%f          XP / seviye / seri
  $(_sc_c green)bp%f               aktif buddy'nin gucunu calistir

$(_sc_c cyan)%BGhostty%b%f

  $(_sc_c green)Alt+Space%f        her yerden acilan terminal (quick terminal)
  $(_sc_c green)Cmd+D / Cmd+Shift+D%f  bolme   $(_sc_c green)Cmd+Shift+Enter%f bolmeyi buyut
"
}

_sc_doctor_line() {
  if [[ "$2" == 1 ]]; then print -P "  %F{${SC_COLOR[green]}}✔%f ${(r:15:)1}%F{${SC_COLOR[muted]}}${3//\%/%%}%f"
  else print -P "  %F{${SC_COLOR[orange]}}✘%f ${(r:15:)1}%F{${SC_COLOR[muted]}}${3//\%/%%}%f"; fi
}

sc_doctor() {
  local ok=0 warn=0 t
  print -P "\n%B%F{${SC_COLOR[cyan]}}systemcmd doctor%f%b  %F{${SC_COLOR[muted]}}tema: $SYSTEMCMD_THEME_NAME · kok: ${SYSTEMCMD_ROOT/#$HOME/~}%f\n"
  local -A pkg=(delta git-delta rg ripgrep nvim neovim claude claude-code ghostty '--cask ghostty')
  for t in fzf bat eza fd zoxide delta rg btop lazygit zellij nvim claude ghostty; do
    local p="$(whence -p $t 2>/dev/null)"
    [[ -z "$p" && $t == ghostty && -d /Applications/Ghostty.app ]] && p=/Applications/Ghostty.app
    if [[ -n "$p" ]]; then _sc_doctor_line "$t" 1 "$p"; (( ok++ ))
    else _sc_doctor_line "$t" 0 "yok -> brew install ${pkg[$t]:-$t}"; (( warn++ )); fi
  done
  local font=0
  local -a fonts=(~/Library/Fonts/*Nerd*(N) /Library/Fonts/*Nerd*(N))
  (( ${#fonts} )) && font=1
  _sc_doctor_line 'nerd font' $font 'JetBrainsMono Nerd Font (ikonlar icin)'; (( font )) && (( ok++ )) || (( warn++ ))
  local gh="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/config"
  if grep -q systemcmd "$gh" 2>/dev/null; then _sc_doctor_line 'ghostty config' 1 "$gh"; (( ok++ ))
  else _sc_doctor_line 'ghostty config' 0 "$gh (macos/install.sh kurar)"; (( warn++ )); fi
  (( ${+ZSH_AUTOSUGGEST_STRATEGY} || ${+_ZSH_AUTOSUGGEST_ASYNC_FD} || ${+functions[_zsh_autosuggest_start]} )) \
    && { _sc_doctor_line 'autosuggest' 1 'aktif'; (( ok++ )); } || { _sc_doctor_line 'autosuggest' 0 'brew install zsh-autosuggestions'; (( warn++ )); }
  (( ${+ZSH_HIGHLIGHT_VERSION} )) \
    && { _sc_doctor_line 'highlighting' 1 "v$ZSH_HIGHLIGHT_VERSION"; (( ok++ )); } || { _sc_doctor_line 'highlighting' 0 'brew install zsh-syntax-highlighting'; (( warn++ )); }
  print -P "\n  %F{${SC_COLOR[green]}}$ok tamam%f · %F{${SC_COLOR[orange]}}$warn eksik%f\n"
}

sc_ports() {
  print -P "%F{${SC_COLOR[cyan]}}Dinlenen portlar%f"
  lsof -nP -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR==1 || !seen[$1 $9]++ {printf "  %-18s %-8s %s\n", $1, $2, $9}'
}

sc_ip() {
  local lan="$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null)"
  print -P "  LAN  %F{${SC_COLOR[green]}}${lan:-yok}%f"
  print -P "  WAN  %F{${SC_COLOR[green]}}$(curl -fsS --max-time 3 https://ifconfig.me 2>/dev/null || print yok)%f"
}

sc_stats() {
  print -P "%F{${SC_COLOR[cyan]}}En cok kullandigin komutlar%f"
  local -A count
  local c
  for c in "${(@v)history}"; do (( count[${c%% *}]++ )); done
  local k
  for k in "${(@k)count}"; do print -r -- "${count[$k]} $k"; done | sort -rn | head -15 |
    awk -v max=0 'NR==1{max=$1} {bar=""; n=int($1*30/max); for(i=0;i<n;i++) bar=bar "█"; printf "  %-14s %5d %s\n", $2, $1, bar}'
}

sc_layout() {
  command -v zellij >/dev/null || { print 'zellij yok: brew install zellij'; return 1; }
  [[ -n "$ZELLIJ" ]] && { print 'Zaten zellij icindesin.'; return 1; }
  zellij --layout "$SYSTEMCMD_ROOT/../terminal/zellij/systemcmd.kdl"
}

sc_update() {
  local repo="${SYSTEMCMD_ROOT:A:h:h}"
  [[ -d "$repo/.git" ]] || { print "Repo bulunamadi: $repo"; return 1; }
  git -C "$repo" pull --ff-only && exec zsh
}

sc_menu() {
  command -v fzf >/dev/null || { sc_keys; return; }
  local items=(
    "run|Proje gorevleri (flutter/npm/cargo...)"
    "buddy|Buddy companion karti"
    "buddyxp|Buddy XP / seviye"
    "buddylist|Buddy koleksiyonu (17 pet)"
    "hub|Komut paleti (hepsini ara + calistir)"
    "keys|Tum kisayollar ve komutlar"
    "doctor|Kurulum kontrolu"
    "theme|Tema degistir"
    "env|.env yukle"
    "layout|Zellij calisma duzeni"
    "ports|Dinlenen portlar"
    "sys|Pil, RAM, disk, ag (ayrintili)"
    "ip|LAN ve WAN IP"
    "dashboard|Canli sistem panosu (CPU/RAM/disk/pil)"
    "wrapped|Kisisel shell raporu"
    "tips|Ipucu galerisi"
    "stats|En cok kullanilan komutlar"
    "config|Ayarlar (~/.systemcmd/config.json)"
    "ssh|SSH baglanti yoneticisi"
    "welcome|Karsilama ekrani"
    "update|systemcmd guncelle (git pull)"
    "core|PowerShell cekirdegi (Buddy, Brain, Live...)"
  )
  local pick
  pick="$(print -rl -- "${items[@]}" | awk -F'|' '{printf "%-8s \033[2m%s\033[0m\t%s\n", $1, $2, $1}' |
    fzf --ansi --height=60% --delimiter=$'\t' --with-nth=1 --prompt='systemcmd > ' \
        --border-label=' systemcmd ' --header='Enter: calistir | Esc: cik')" || return
  sc "${pick##*$'\t'}"
}

systemcmd() {
  local cmd="${1:-menu}"
  (( $# )) && shift
  case "$cmd" in
    menu) sc_menu ;;
    help|keys|-h|--help) sc_keys ;;
    doctor) sc_doctor ;;
    theme)
      case "$1" in
        share) sc_theme_share ;;
        install) sc_theme_install "$2" ;;
        *) sc_theme_set "$@" ;;
      esac ;;
    run) sc_run ;;
    env) if [[ "$1" == off ]]; then sc_env_unload; else sc_env "$@"; fi ;;
    ask) sc_ai_ask "$@" ;;
    explain) sc_ai_explain "$@" ;;
    fix) sc_fix ;;
    layout) sc_layout ;;
    ports) sc_ports ;;
    ip) sc_ip ;;
    sys|info|pil|battery) sc_sys ;;
    dashboard|dash) sc_dashboard ;;
    tips) sc_tips ;;
    tip) sc_tip ;;
    wrapped) sc_wrapped ;;
    config|cfg) sc_config "$@" ;;
    ssh) sc_ssh "$2" "$3" ;;
    stats) sc_stats ;;
    welcome) sc_welcome ;;
    buddy) buddy "$@" ;;
    bp|power) bp ;;
    buddyxp|xp) buddyxp ;;
    buddylist) buddylist ;;
    hub|systemcmdhelp) sc_hub ;;
    version|surum) sc_version ;;
    perf) sc_perf ;;
    update) sc_update ;;
    core)
      local bridge="${SYSTEMCMD_ROOT:A:h:h}/shell/Invoke-SystemCmd.ps1"
      command -v pwsh >/dev/null && [[ -f "$bridge" ]] \
        && command pwsh -NoLogo -NoProfile -File "$bridge" "$@" \
        || print 'PowerShell cekirdegi icin pwsh ve repo gerekli.' ;;
    *) print -P "%F{${SC_COLOR[red]}}Bilinmeyen komut:%f $cmd"; sc_keys; return 1 ;;
  esac
}
sc() { systemcmd "$@"; }

# ── systemcmdhelp: her sey tek fzf paletinde (ara + Enter ile calistir) ─────
sc_hub() {
  command -v fzf >/dev/null || { sc_keys; return; }
  local R=$'\t'
  local -a items=(
    "KISAYOL${R}Ctrl+R${R}favorili gecmis arama (f/Ctrl+S favori)${R}:"
    "KISAYOL${R}Ctrl+F${R}baglamsal dosya secici${R}:"
    "KISAYOL${R}Ctrl+G${R}git gezgini (dosya/branch/commit/stash)${R}:"
    "KISAYOL${R}Ctrl+P${R}proje atlama${R}:"
    "KISAYOL${R}Alt+Space${R}Ghostty quick terminal${R}:"
    "AI${R}sc ask${R}Claude'a soru sor${R}read -r 'q?soru: ' && sc ask \$q"
    "AI${R}fix${R}son hatali komutu duzelt${R}fix"
    "SISTEM${R}sc sys${R}pil/RAM/disk/ag ayrintili${R}sc sys"
    "SISTEM${R}sc dashboard${R}canli sistem panosu${R}sc dashboard"
    "SISTEM${R}ip${R}ag bilgisi${R}ip"
    "SISTEM${R}para${R}USD/EUR -> TRY${R}read -r 'a?miktar: ' && para \$a"
    "GIT${R}gst${R}kisa git durumu${R}gst"
    "GIT${R}gco${R}interaktif branch checkout${R}gco"
    "GIT${R}glog${R}interaktif commit gezgini${R}glog"
    "GIT${R}gstash${R}stash gezgini${R}gstash"
    "GIT${R}gwip${R}hizli wip commit${R}gwip"
    "PROJE${R}sc run${R}proje gorevleri${R}sc run"
    "PROJE${R}sc env${R}.env yukle${R}sc env"
    "PROJE${R}sc layout${R}zellij calisma duzeni${R}sc layout"
    "SHELL${R}sc wrapped${R}kisisel shell raporu${R}sc wrapped"
    "SHELL${R}sc stats${R}en cok kullanilan komutlar${R}sc stats"
    "SHELL${R}sc tips${R}ipucu galerisi${R}sc tips"
    "SHELL${R}sc theme${R}tema degistir${R}sc theme"
    "SHELL${R}sc config${R}ayarlar${R}sc config"
    "SHELL${R}cloudhelp${R}Claude Code TR referansi${R}cloudhelp"
    "SSH${R}sc ssh${R}baglanti yoneticisi${R}sc ssh"
    "BUDDY${R}buddy${R}companion karti${R}buddy"
    "BUDDY${R}buddy hatch${R}yumurtayi kir${R}buddy hatch"
    "BUDDY${R}buddyxp${R}XP / seviye${R}buddyxp"
    "BUDDY${R}bp${R}aktif buddy gucu${R}bp"
    "BUDDY${R}buddylist${R}koleksiyon${R}buddylist"
    "SISTEM${R}sc doctor${R}kurulum kontrolu${R}sc doctor"
    "SISTEM${R}sc version${R}surum bilgisi${R}sc version"
  )
  local sel
  sel="$(print -rl -- "${items[@]}" |
    awk -F'\t' '{printf "\033[38;5;245m%-8s\033[0m \033[97m%-14s\033[0m \033[38;5;245m%s\033[0m\t%s\n", $1,$2,$3,$4}' |
    fzf --ansi --delimiter='\t' --with-nth=1 --prompt='systemcmdhelp > ' \
      --border-label=' systemcmd ' --height=85% \
      --header='Yaz: ara · Enter: calistir · Esc: cik')" || return
  local cmd="${sel##*$'\t'}"
  [[ -z "$cmd" || "$cmd" == ':' ]] && { print -P "  %F{${SC_COLOR[muted]}}Bu bir kisayol — klavyeden kullan.%f"; return; }
  print -z -- "$cmd"
}

sc_version() {
  local root="${SYSTEMCMD_ROOT:A:h:h}"
  local rev="?" date="?"
  if [[ -d "$root/.git" ]]; then
    rev="$(git -C "$root" rev-parse --short HEAD 2>/dev/null)"
    date="$(git -C "$root" log -1 --format=%cd --date=short 2>/dev/null)"
  fi
  print -P "\n  %B%F{${SC_COLOR[cyan]}}systemcmd%f%b %F{${SC_COLOR[muted]}}native zsh (macOS)%f"
  print -P "  %F{${SC_COLOR[muted]}}surum%f $rev  %F{${SC_COLOR[muted]}}· $date · $(sw_vers -productName) $(sw_vers -productVersion)%f"
  print -P "  %F{${SC_COLOR[muted]}}buddy cekirdegi:%f ${SYSTEMCMD_CORE:-yok}\n"
}

sc_perf() {
  print -P "  %F{${SC_COLOR[muted]}}acilis suresi olculuyor (5 ornek)...%f"
  local i t total=0
  for i in {1..5}; do
    t="$( { /usr/bin/time zsh -i -c exit ; } 2>&1 | awk '/real/{print $1}' | tr ',' '.' )"
    print -P "    #$i  %F{${SC_COLOR[cyan]}}${t}s%f"
    total=$(( total + t ))
  done
  print -P "  %F{${SC_COLOR[green]}}ortalama: $(printf '%.3f' $(( total / 5.0 )))s%f\n"
}
alias systemcmdhelp='sc_hub'
