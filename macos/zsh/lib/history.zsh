# Ctrl+R: favorili gecmis aramasi (Windows/Linux surumuyle ayni mantik)
#
#   f          favori ac/kapat (arama kutusu bossa; Windows'taki gibi)
#   Ctrl+S     favori ac/kapat (her zaman, arama yazarken de)
#   Ctrl+R     siralamayi ac/kapat
#   Enter      komutu satira getirir (calistirmaz)
#
# Favoriler: ~/.systemcmd-history-favorites (satir basina bir komut, Linux ile ayni dosya)
# Cok satirli komutlarda yeni satir \x1f olarak saklanir.

typeset -g SYSTEMCMD_HISTORY_FAVORITES_PATH="${SYSTEMCMD_HISTORY_FAVORITES_PATH:-$HOME/.systemcmd-history-favorites}"

_sc_fav_read() {
  reply=()
  [[ -r "$SYSTEMCMD_HISTORY_FAVORITES_PATH" ]] || return 0
  local line
  local -A seen
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" || -n "${seen[$line]}" ]] && continue
    seen[$line]=1
    reply+=("${line//$'\x1f'/$'\n'}")
  done < "$SYSTEMCMD_HISTORY_FAVORITES_PATH"
}

_sc_fav_write() {
  local item
  : >| "$SYSTEMCMD_HISTORY_FAVORITES_PATH"
  for item in "$@"; do
    print -r -- "${item//$'\n'/$'\x1f'}" >> "$SYSTEMCMD_HISTORY_FAVORITES_PATH"
  done
}

# Ilk eslesmede favoriye ekler (en uste), varsa cikarir
_sc_fav_toggle() {
  local cmd="$1" item found=0
  local -a reply updated
  _sc_fav_read
  for item in "${reply[@]}"; do
    if [[ "$item" == "$cmd" ]]; then found=1; continue; fi
    updated+=("$item")
  done
  (( found )) || updated=("$cmd" "${updated[@]}")
  _sc_fav_write "${updated[@]}"
}

sc_history_summary() {
  local c="${(L)1}"
  case "$c" in
    git\ status*) REPLY='Repo durumunu gosterir.' ;;
    git\ pull*) REPLY='Uzak degisiklikleri ceker.' ;;
    git\ push*) REPLY='Commitleri uzak depoya yollar.' ;;
    git\ commit*) REPLY='Yeni commit olusturur.' ;;
    git\ add*) REPLY='Dosyalari stage alanina ekler.' ;;
    git\ switch*|git\ checkout*) REPLY='Branch veya dosya degistirir.' ;;
    git\ restore*|git\ reset*) REPLY='Degisiklikleri geri alir.' ;;
    git\ log*) REPLY='Commit gecmisini gosterir.' ;;
    git\ diff*) REPLY='Degisiklik farkini gosterir.' ;;
    git\ clone*) REPLY='Depoyu klonlar.' ;;
    flutter\ run*) REPLY='Flutter uygulamasini cihazda calistirir.' ;;
    flutter\ build\ apk*|flutter\ build\ appbundle*) REPLY='Android surumu derler.' ;;
    flutter\ build\ ios*|flutter\ build\ ipa*) REPLY='iOS surumu derler.' ;;
    flutter\ pub\ get*) REPLY='Dart paketlerini ceker.' ;;
    flutter\ clean*) REPLY='Flutter build onbellegini temizler.' ;;
    flutter\ test*) REPLY='Flutter testlerini calistirir.' ;;
    flutter\ analyze*|dart\ analyze*) REPLY='Kod analizi yapar.' ;;
    flutter*) REPLY='Flutter komutu calistirir.' ;;
    pod\ install*) REPLY='iOS CocoaPods bagimliliklarini kurar.' ;;
    brew\ install*) REPLY='Homebrew paketi kurar.' ;;
    brew\ upgrade*|brew\ update*) REPLY='Homebrew paketlerini gunceller.' ;;
    brew*) REPLY='Homebrew komutu calistirir.' ;;
    npm\ run\ dev*|pnpm\ dev*|pnpm\ run\ dev*|yarn\ dev*|bun\ dev*) REPLY='Gelistirme sunucusunu baslatir.' ;;
    npm\ run\ build*|pnpm\ build*|pnpm\ run\ build*|yarn\ build*) REPLY='Projeyi derler.' ;;
    npm\ test*|npm\ run\ test*|pnpm\ test*|yarn\ test*) REPLY='Testleri calistirir.' ;;
    npm\ install*|npm\ i\ *|npm\ i|pnpm\ install*|yarn\ install*|bun\ install*) REPLY='JavaScript bagimliliklarini kurar.' ;;
    npx\ *) REPLY='npm paketini gecici calistirir.' ;;
    docker\ ps*) REPLY='Calisan containerlari listeler.' ;;
    docker\ compose\ up*|docker-compose\ up*) REPLY='Servisleri ayaga kaldirir.' ;;
    docker\ compose\ down*|docker-compose\ down*) REPLY='Servisleri durdurur.' ;;
    docker\ logs*) REPLY='Container loglarini gosterir.' ;;
    docker\ exec*|docker\ run*) REPLY='Container icinde komut calistirir.' ;;
    docker\ build*) REPLY='Docker imaji derler.' ;;
    kubectl\ get*) REPLY='Kubernetes kaynaklarini listeler.' ;;
    kubectl\ apply*) REPLY='Manifest degisikliklerini uygular.' ;;
    kubectl\ logs*) REPLY='Pod loglarini gosterir.' ;;
    python*|py\ *) REPLY='Python komutu calistirir.' ;;
    pip\ install*|pip3\ install*) REPLY='Python paketi kurar.' ;;
    uv\ run*) REPLY='Komutu uv ortaminda calistirir.' ;;
    uv\ sync*) REPLY='Python bagimliliklarini senkronlar.' ;;
    cargo\ run*) REPLY='Rust uygulamasini calistirir.' ;;
    cargo\ build*) REPLY='Rust projesini derler.' ;;
    cargo\ test*) REPLY='Rust testlerini calistirir.' ;;
    go\ run*) REPLY='Go kodunu calistirir.' ;;
    go\ build*) REPLY='Go binary dosyasi uretir.' ;;
    go\ test*) REPLY='Go testlerini calistirir.' ;;
    dotnet\ *) REPLY='.NET komutu calistirir.' ;;
    claude*) REPLY='Claude Code oturumu acar.' ;;
    code\ *|code|nvim*|vim*) REPLY='Editoru acar.' ;;
    ssh\ *) REPLY='Uzak sunucuya baglanir.' ;;
    scp\ *|rsync\ *) REPLY='Dosya aktarimi yapar.' ;;
    curl\ *|wget\ *) REPLY='Veri indirir veya istek atar.' ;;
    sudo\ *) REPLY='Komutu yonetici olarak calistirir.' ;;
    cd\ *|cd|z\ *) REPLY='Klasor degistirir.' ;;
    ls*|ll*|la*|lt*|eza*) REPLY='Klasor icerigini listeler.' ;;
    mkdir\ *|mkcd\ *) REPLY='Yeni klasor olusturur.' ;;
    rm\ *) REPLY='Dosya veya klasor siler.' ;;
    cp\ *) REPLY='Dosya kopyalar.' ;;
    mv\ *) REPLY='Dosya veya klasoru tasir.' ;;
    open\ *) REPLY='Dosya/uygulamayi Finder ile acar.' ;;
    btop*|htop*|top*) REPLY='Canli sistem kullanimini gosterir.' ;;
    lsof\ *) REPLY='Acik dosya/portlari listeler.' ;;
    kill*|pkill*) REPLY='Islem sonlandirir.' ;;
    pwsh*) REPLY='PowerShell komutu calistirir.' ;;
    sc\ *|sc|systemcmd*) REPLY='systemcmd komutu.' ;;
    *) REPLY="'${1%% *}' komutunu calistirir." ;;
  esac
}

sc-history-widget() {
  if ! command -v fzf >/dev/null; then
    zle -M 'fzf bulunamadi: brew install fzf'
    return 1
  fi

  # Gecmisi yeniden eskiye, tekrarsiz topla (cok satirli komutlar korunur)
  local -a entries ordered
  local -A seen favset
  local key cmd
  for key in ${(Onk)history}; do
    cmd="${history[$key]}"
    [[ -z "${cmd//[[:space:]]/}" || -n "${seen[$cmd]}" ]] && continue
    seen[$cmd]=1
    entries+=("$cmd")
  done

  local query="$BUFFER" preview_file="$SYSTEMCMD_HOME/history-preview.txt"
  local -a reply lines
  local out item display marker summary i sel idx action
  local star=$'\e[38;2;'"$(_sc_hex2rgb "${SC_COLOR[orange]}")m"

  while true; do
    _sc_fav_read
    favset=()
    for item in "${reply[@]}"; do favset[$item]=1; done

    # Favoriler ustte (favori sirasiyla), sonra gecmis
    ordered=("${reply[@]}")
    for item in "${entries[@]}"; do
      [[ -n "${favset[$item]}" ]] || ordered+=("$item")
    done

    # Sag panel: favori listesi
    {
      print -r -- "Favoriler"
      print
      if (( ${#reply} == 0 )); then
        print -r -- "Henuz favori yok. Bir satirda f'ye bas."
      else
        i=1
        for item in "${reply[@]}"; do
          sc_history_summary "$item"
          display="${item//$'\n'/ ⏎ }"
          (( ${#display} > 70 )) && display="${display[1,70]}…"
          printf '[%02d] %s\n     %s\n' $i "$display" "$REPLY"
          (( i++ ))
        done
      fi
    } >| "$preview_file"

    out="$(
      i=1
      for item in "${ordered[@]}"; do
        display="${item//$'\n'/ ⏎ }"
        display="${display//$'\t'/ }"
        (( ${#display} > 220 )) && display="${display[1,220]}…"
        sc_history_summary "$item"
        if [[ -n "${favset[$item]}" ]]; then
          marker="${star}★"$'\e[0m'
          display="${star}${display}"$'\e[0m'
        else
          marker=' '
        fi
        printf '%s \e[2m%04d\e[0m %s\t%d\t%s\n' "$marker" $i "$display" $i "$REPLY"
        (( i++ ))
      done | fzf --ansi --height=80% --layout=reverse --border=rounded \
          --delimiter=$'\t' --with-nth=1 --nth=1 --no-sort --tiebreak=index \
          --print-query --expect=ctrl-s \
          --prompt='history > ' --border-label=' systemcmd ' \
          --header='f / Ctrl+S: favori ac/kapat  |  Ctrl+R: siralama  |  Enter: satira getir' \
          --bind='ctrl-r:toggle-sort' \
          --bind='f:transform:[[ -z {q} ]] && echo "print(__fav__)+accept" || echo "put(f)"' \
          --preview="printf '\033[1m%s\033[0m\n\n' {3}; cat ${(q)preview_file}" \
          --preview-window='right,45%,wrap,border-left' \
          --query="$query"
    )" || { zle reset-prompt; return 0; }

    lines=("${(@f)out}")
    query="${lines[1]}"
    action="${lines[2]}"
    sel="${lines[-1]}"
    [[ "${lines[(r)__fav__]}" == __fav__ ]] && action=__fav__
    idx="${${sel#*$'\t'}%%$'\t'*}"
    [[ "$idx" == <-> ]] || { zle reset-prompt; return 0; }
    cmd="${ordered[$idx]}"

    if [[ "$action" == ctrl-s || "$action" == __fav__ ]]; then
      _sc_fav_toggle "$cmd"
      continue
    fi

    BUFFER="$cmd"
    CURSOR=${#BUFFER}
    zle reset-prompt
    return 0
  done
}

_sc_hex2rgb() {
  local h="${1#\#}"
  print -r -- "$(( 16#${h[1,2]} ));$(( 16#${h[3,4]} ));$(( 16#${h[5,6]} ))"
}

zle -N sc-history-widget
bindkey '^R' sc-history-widget
