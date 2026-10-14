# Sistem bilgisi (macOS): pil, disk, RAM, ag, yuk — macOS'un kendi gosterdigiyle ayni
# Degerler SC_SYS dizisine yazilir; welcome ve `sc sys` kullanir.

typeset -gA SC_SYS

# GB: Finder/Ayarlar gibi ondalik (1 GB = 1000^3)
_sc_gb() { printf '%.1f' $(( $1 / 1e9 )); }
# RAM: Etkinlik Izleyicisi gibi ikili (8 GiB -> "8")
_sc_gib() { local v=$(( $1 / 1073741824.0 )); (( v == ${v%.*} )) && printf '%d' ${v%.*} || printf '%.1f' $v; }

_sc_sys_battery() {
  local out line pct state remain="" src
  out="$(pmset -g batt 2>/dev/null)" || return
  src="${${out%%$'\n'*}#*\'}"; src="${src%\'*}"          # 'AC Power' / 'Battery Power'
  line="${${(@M)${(@f)out}:#*InternalBattery*}[1]}"
  if [[ -z "$line" ]]; then SC_SYS[batt]=''; SC_SYS[batt_state]='ac'; return; fi
  pct="${${line#*$'\t'}%%\%*}"
  state="${${line#*%; }%%;*}"                             # charging / discharging / charged / AC attached
  [[ "$line" =~ '([0-9]+:[0-9][0-9]) remaining' ]] && remain="${match[1]}"
  SC_SYS[batt]="$pct"
  case "$state" in
    discharging) SC_SYS[batt_state]=discharging ;;
    charging|'finishing charge') SC_SYS[batt_state]=charging ;;
    charged) SC_SYS[batt_state]=full ;;
    *) [[ "$src" == 'AC Power' ]] && SC_SYS[batt_state]=plugged || SC_SYS[batt_state]=discharging ;;
  esac
  # 16:33 -> 16sa 33dk ; 0:00 / tahmin yok -> bos
  SC_SYS[batt_time]=''
  if [[ "$remain" == <->:<-> && "$remain" != 0:00 ]]; then
    local h="${remain%%:*}" m="${remain#*:}"
    (( h > 0 )) && SC_SYS[batt_time]="${h}sa ${m#0}dk" || SC_SYS[batt_time]="${m#0}dk"
  fi
}

_sc_sys_memory() {
  local vm total page anon purg wired comp
  vm="$(vm_stat 2>/dev/null)" || return
  total="$(sysctl -n hw.memsize 2>/dev/null)"
  page="${${${(@M)${(@f)vm}:#*page size of*}[1]##*page size of }%% *}"
  _sc_vmval() { local l="${${(@M)${(@f)vm}:#$1:*}[1]}"; l="${l##*:}"; l="${l//[^0-9]/}"; print -r -- "${l:-0}"; }
  anon=$(_sc_vmval 'Anonymous pages'); purg=$(_sc_vmval 'Pages purgeable')
  wired=$(_sc_vmval 'Pages wired down'); comp=$(_sc_vmval 'Pages occupied by compressor')
  unfunction _sc_vmval
  # Etkinlik Izleyicisi "Kullanilan Bellek" = uygulama + kablolu + sikistirilmis
  SC_SYS[mem_used]=$(( (anon - purg + wired + comp) * page ))
  SC_SYS[mem_total]=$total
}

_sc_sys_disk() {
  # Finder'in "kullanilabilir" degeri (silinebilir alan dahil); arka planda tazelenir
  local cache="$SYSTEMCMD_HOME/disk-cache" avail total
  [[ -r "$cache" ]] && IFS=' ' read -r avail total < "$cache"
  if [[ -z "$avail" ]]; then
    # Onbellek yoksa df ile (ondalik GB'ye cevrilmis) yaklasik deger
    local -a d=(${(z)${${(f)"$(df -k /System/Volumes/Data 2>/dev/null)"}[2]}})
    avail=$(( d[4] * 1024 )); total=$(( d[2] * 1024 ))
  fi
  SC_SYS[disk_free]=$avail SC_SYS[disk_total]=$total
  ( osascript -l JavaScript -e 'ObjC.import("Foundation");var u=$.NSURL.fileURLWithPath("/"),a=Ref(),t=Ref();u.getResourceValueForKeyError(a,$.NSURLVolumeAvailableCapacityForImportantUsageKey,null);u.getResourceValueForKeyError(t,$.NSURLVolumeTotalCapacityKey,null);a[0].js+" "+t[0].js' \
      >| "$cache.tmp" 2>/dev/null && [[ -s "$cache.tmp" ]] && mv -f "$cache.tmp" "$cache" ) &>/dev/null &!
}

_sc_sys_net() {
  local iface ip
  iface="$(route -n get default 2>/dev/null | awk '/interface:/ {print $2; exit}')"
  [[ -n "$iface" ]] && ip="$(ipconfig getifaddr "$iface" 2>/dev/null)"
  SC_SYS[iface]="$iface" SC_SYS[ip]="$ip"
  # utun/ppp = VPN
  [[ "$iface" == (utun|ppp|ipsec)* ]] && SC_SYS[vpn]=1 || SC_SYS[vpn]=''
}

_sc_sys_load() {
  local -a s=("${(@f)$(sysctl -n vm.loadavg hw.ncpu kern.boottime 2>/dev/null)}")
  local l="${${(z)s[1]}[2]}"
  SC_SYS[load]="${l//,/.}" SC_SYS[ncpu]="${s[2]}"
  local boot="${${s[3]#*sec = }%%,*}"
  if [[ "$boot" == <-> ]]; then
    local t=$(( EPOCHSECONDS - boot )) up
    up="$(( t % 86400 / 3600 ))sa $(( t % 3600 / 60 ))dk"
    (( t >= 86400 )) && up="$(( t / 86400 ))g $up"
    SC_SYS[uptime]="$up"
  fi
}

sc_sys_collect() {
  SC_SYS=()
  _sc_sys_battery; _sc_sys_memory; _sc_sys_disk; _sc_sys_net; _sc_sys_load
}

# Pil metni: "88% · 16sa 33dk kaldi" / "95% ⚡ sarj oluyor" / "100% ⚡ dolu"
sc_sys_batt_text() {
  [[ -z "${SC_SYS[batt]}" ]] && { print -r -- 'yok (AC)'; return; }
  local p="${SC_SYS[batt]}%" t="${SC_SYS[batt_time]}"
  case "${SC_SYS[batt_state]}" in
    charging)    print -r -- "$p ⚡ sarj oluyor${t:+ · $t'da dolar}" ;;
    full)        print -r -- "$p ⚡ dolu" ;;
    plugged)     print -r -- "$p ⚡ prizde (sarj etmiyor)" ;;
    *)           print -r -- "$p${t:+ · $t kaldi}" ;;
  esac
}

sc_sys_batt_color() {
  local p="${SC_SYS[batt]:-100}"
  [[ "${SC_SYS[batt_state]}" == (charging|full|plugged) ]] && { print -r -- "${SC_COLOR[green]}"; return; }
  (( p <= 15 )) && print -r -- "${SC_COLOR[red]}" && return
  (( p <= 35 )) && print -r -- "${SC_COLOR[orange]}" && return
  print -r -- "${SC_COLOR[fg]}"
}

# sc sys: ayrintili rapor (yavas kaynaklar burada: model, pil sagligi)
sc_sys() {
  sc_sys_collect
  local m="${SC_COLOR[muted]}" f="${SC_COLOR[fg]}" c="${SC_COLOR[cyan]}"
  local hw="$(system_profiler SPHardwareDataType SPPowerDataType 2>/dev/null)"
  _sc_field() { local l="${${(@M)${(@f)hw}:#*$1:*}[1]}"; print -r -- "${${l#*: }## }"; }
  local model="$(_sc_field 'Model Name')" chip="$(_sc_field 'Chip')" cycles="$(_sc_field 'Cycle Count')"
  local cond="$(_sc_field 'Condition')" maxcap="$(_sc_field 'Maximum Capacity')"
  unfunction _sc_field
  local row
  row() { print -P "  %F{$m}${(r:12:)1}%f %F{$f}${2//\%/%%}%f"; }
  print -P "\n  %B%F{$c}${model:-Mac}%f%b %F{$m}· ${chip} · macOS $(sw_vers -productVersion)%f\n"
  row 'pil'      "$(sc_sys_batt_text)"
  [[ -n "$cycles" ]] && row 'pil sagligi' "${maxcap:-?} kapasite · ${cycles} dongu · ${cond:-?}"
  row 'bellek'   "$(_sc_gib ${SC_SYS[mem_used]}) / $(_sc_gib ${SC_SYS[mem_total]}) GB kullaniliyor"
  row 'disk'     "$(_sc_gb ${SC_SYS[disk_free]}) GB bos / $(_sc_gb ${SC_SYS[disk_total]}) GB"
  row 'ag'       "${SC_SYS[ip]:-baglanti yok}${SC_SYS[iface]:+ (${SC_SYS[iface]})}${SC_SYS[vpn]:+ · VPN}"
  row 'yuk'      "${SC_SYS[load]} (${SC_SYS[ncpu]} cekirdek)"
  row 'acik'     "${SC_SYS[uptime]}"
  print
  unfunction row
}
