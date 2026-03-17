# shellcheck shell=bash

case $- in
  *i*) ;;
  *) return ;;
esac

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:---layout=reverse --border}"
export SYSTEMCMD_HOME="${HOME}/.config/systemcmd"
export SYSTEMCMD_HISTORY_FAVORITES_PATH="${SYSTEMCMD_HISTORY_FAVORITES_PATH:-${HOME}/.systemcmd-history-favorites}"
export SYSTEMCMD_HISTORY_PREVIEW_PATH="${SYSTEMCMD_HOME}/history-preview.txt"
export SYSTEMCMD_FZF_SKIP_DIRS='.git,node_modules,dist,build,target,.venv,venv,__pycache__,.next,.nuxt,.cache,bin,obj,vendor,coverage,out,release,debug,.pytest_cache,.mypy_cache,.tox'
SYSTEMCMD_SCRIPT_DIR="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ -f "${SYSTEMCMD_HOME}/systemcmd-theme.generated.sh" ]]; then
  # shellcheck disable=SC1090
  . "${SYSTEMCMD_HOME}/systemcmd-theme.generated.sh"
elif [[ -f "${SYSTEMCMD_SCRIPT_DIR}/systemcmd-theme.generated.sh" ]]; then
  # shellcheck disable=SC1091
  . "${SYSTEMCMD_SCRIPT_DIR}/systemcmd-theme.generated.sh"
else
  export SYSTEMCMD_FZF_COLOR='fg:#d1d1d1,fg+:#5effc3,bg:-1,bg+:-1,gutter:-1,prompt:#5ac8ff,pointer:#ff5eed,marker:#5effc3,spinner:#5ac8ff,hl:#5c78ff,hl+:#5ac8ff,info:#7e7e7e,border:#2f2f2f,preview-border:#2f2f2f'
fi

mkdir -p "${SYSTEMCMD_HOME}"

if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
  alias ls='ls --color=auto'
fi

alias ll='ls -alF'

if command -v batcat >/dev/null 2>&1; then
  export SYSTEMCMD_BAT='batcat'
  export SYSTEMCMD_PREVIEW='batcat --style=numbers --color=always --paging=never --line-range :300 {}'
elif command -v bat >/dev/null 2>&1; then
  export SYSTEMCMD_BAT='bat'
  export SYSTEMCMD_PREVIEW='bat --style=numbers --color=always --paging=never --line-range :300 {}'
else
  export SYSTEMCMD_BAT='cat'
  export SYSTEMCMD_PREVIEW='cat {}'
fi

system_ram_info() {
  free -m 2>/dev/null | awk '/^Mem:/ {printf "Used RAM: %.2f GB | Free RAM: %.2f GB", $3 / 1024, $4 / 1024}'
}

system_cpu_info() {
  LC_ALL=C top -bn1 2>/dev/null | awk -F'[, ]+' '/Cpu\(s\)/ {printf "CPU Usage: %.1f%%", 100 - $8; exit}'
}

system_local_ip() {
  hostname -I 2>/dev/null | awk '{print "Local IP: " $1}'
}

systemcmd_has_fzf_walker() {
  if [[ -n "${SYSTEMCMD_FZF_HAS_WALKER:-}" ]]; then
    [[ "${SYSTEMCMD_FZF_HAS_WALKER}" == '1' ]]
    return
  fi

  if command -v fzf >/dev/null 2>&1 && fzf --help 2>/dev/null | grep -q -- '--walker'; then
    SYSTEMCMD_FZF_HAS_WALKER='1'
  else
    SYSTEMCMD_FZF_HAS_WALKER='0'
  fi

  [[ "${SYSTEMCMD_FZF_HAS_WALKER}" == '1' ]]
}

systemcmd_current_token_bounds() {
  local line="${READLINE_LINE}"
  local point="${READLINE_POINT:-0}"
  local length=${#line}
  local left right token

  if (( length == 0 )); then
    printf '0\t0\t\n'
    return
  fi

  if (( point > length )); then
    point=${length}
  fi

  left=${point}
  while (( left > 0 )); do
    if [[ "${line:left-1:1}" == ' ' || "${line:left-1:1}" == $'\t' ]]; then
      break
    fi
    ((left--))
  done

  right=${point}
  while (( right < length )); do
    if [[ "${line:right:1}" == ' ' || "${line:right:1}" == $'\t' ]]; then
      break
    fi
    ((right++))
  done

  token="${line:left:right-left}"
  token="${token%\"}"
  token="${token#\"}"
  token="${token%\'}"
  token="${token#\'}"
  printf '%s\t%s\t%s\n' "${left}" "${right}" "${token}"
}

systemcmd_resolve_dir_token() {
  local token="$1"
  local candidate

  [[ -z "${token}" ]] && return 1

  case "${token}" in
    "~"*) token="${HOME}${token:1}" ;;
  esac

  if [[ -d "${token}" ]]; then
    (cd "${token}" 2>/dev/null && pwd -P)
    return
  fi

  return 1
}

systemcmd_quote_path() {
  local path="$1"
  if [[ "${path}" == *[[:space:]]* ]]; then
    printf '"%s"' "${path}"
  else
    printf '%s' "${path}"
  fi
}

systemcmd_replace_current_token() {
  local replacement="$1"
  local left right token
  IFS=$'\t' read -r left right token < <(systemcmd_current_token_bounds)

  READLINE_LINE="${READLINE_LINE:0:left}${replacement}${READLINE_LINE:right}"
  READLINE_POINT=$(( left + ${#replacement} ))
}

systemcmd_list_shallow() {
  local root="$1"

  find "${root}" -mindepth 1 -maxdepth 1 -type d -print 2>/dev/null
  find "${root}" -mindepth 1 -maxdepth 1 ! -type d -print 2>/dev/null
}

systemcmd_find_with_prune() {
  local root="$1"
  local first=1
  local skip_dir
  local -a find_args skip_dirs

  IFS=',' read -r -a skip_dirs <<< "${SYSTEMCMD_FZF_SKIP_DIRS}"
  find_args=("${root}" -mindepth 1)

  if ((${#skip_dirs[@]} > 0)); then
    find_args+=('(')
    for skip_dir in "${skip_dirs[@]}"; do
      if (( first == 0 )); then
        find_args+=(-o)
      fi
      find_args+=(-name "${skip_dir}")
      first=0
    done
    find_args+=(')' -prune -o -print)
  else
    find_args+=(-print)
  fi

  find "${find_args[@]}" 2>/dev/null
}

systemcmd_run_file_picker() {
  local root="$1"
  local initial_query="$2"
  local directory_mode="$3"
  local selected
  local -a fzf_args

  fzf_args=(
    --layout reverse
    --border
    --cycle
    --prompt 'files > '
    --preview "${SYSTEMCMD_PREVIEW}"
    --preview-window 'right:60%:wrap'
    --color "${SYSTEMCMD_FZF_COLOR}"
  )

  if [[ -n "${initial_query}" ]]; then
    fzf_args+=(--query "${initial_query}")
  fi

  if [[ "${directory_mode}" == '1' ]]; then
    selected="$(systemcmd_list_shallow "${root}" | fzf "${fzf_args[@]}")" || return 1
    printf '%s\n' "${selected}"
    return 0
  fi

  if systemcmd_has_fzf_walker; then
    selected="$(
      cd "${root}" 2>/dev/null && \
      fzf "${fzf_args[@]}" \
        --scheme path \
        --walker 'file,dir,hidden' \
        --walker-root "${root}" \
        --walker-skip "${SYSTEMCMD_FZF_SKIP_DIRS}"
    )" || return 1

    if [[ "${selected}" != /* ]]; then
      selected="${root%/}/${selected}"
    fi
    printf '%s\n' "${selected}"
    return 0
  fi

  selected="$(
    systemcmd_find_with_prune "${root}" |
      sed "s#^${root%/}/##" |
      fzf "${fzf_args[@]}"
  )" || return 1

  if [[ "${selected}" != /* ]]; then
    selected="${root%/}/${selected}"
  fi
  printf '%s\n' "${selected}"
}

systemcmd_get_history_entries() {
  builtin history |
    sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//' |
    awk '{
      lines[NR] = $0
    }
    END {
      for (i = NR; i >= 1; i--) {
        if (length(lines[i]) == 0) {
          continue
        }
        if (!seen[lines[i]]++) {
          print lines[i]
        }
      }
    }'
}

systemcmd_get_favorites() {
  if [[ ! -f "${SYSTEMCMD_HISTORY_FAVORITES_PATH}" ]]; then
    return
  fi

  awk 'NF && !seen[$0]++ { print $0 }' "${SYSTEMCMD_HISTORY_FAVORITES_PATH}"
}

systemcmd_save_favorites() {
  : > "${SYSTEMCMD_HISTORY_FAVORITES_PATH}"
  if (($# > 0)); then
    printf '%s\n' "$@" > "${SYSTEMCMD_HISTORY_FAVORITES_PATH}"
  fi
}

systemcmd_history_summary() {
  local command="$1"
  local normalized

  normalized="$(printf '%s' "${command}" | tr '\t' ' ' | tr '[:upper:]' '[:lower:]')"

  case "${normalized}" in
    git\ status*) printf 'Repo durumunu gosterir.' ;;
    git\ pull*) printf 'Uzak degisiklikleri ceker.' ;;
    git\ push*) printf 'Commitleri uzak depoya yollar.' ;;
    git\ commit*) printf 'Yeni commit olusturur.' ;;
    git\ add*) printf 'Dosyalari stage alanina ekler.' ;;
    git\ switch*|git\ checkout*) printf 'Branch veya dosya degistirir.' ;;
    git\ restore*|git\ reset*) printf 'Degisiklikleri geri alir.' ;;
    npm\ run\ dev*|pnpm\ dev*|pnpm\ run\ dev*|yarn\ dev*) printf 'Gelistirme sunucusunu baslatir.' ;;
    npm\ run\ build*|pnpm\ build*|pnpm\ run\ build*|yarn\ build*) printf 'Projeyi derler.' ;;
    npm\ test*|npm\ run\ test*|pnpm\ test*|pnpm\ run\ test*|yarn\ test*) printf 'Testleri calistirir.' ;;
    npm\ install*|npm\ i*|pnpm\ install*|yarn\ install*) printf 'JavaScript bagimliliklarini kurar.' ;;
    docker\ ps*) printf 'Calisan containerlari listeler.' ;;
    docker\ compose\ up*) printf 'Servisleri ayaga kaldirir.' ;;
    docker\ compose\ down*) printf 'Servisleri durdurur.' ;;
    docker\ logs*|docker\ log*) printf 'Container loglarini gosterir.' ;;
    docker\ exec*|docker\ run*) printf 'Container icinde komut calistirir.' ;;
    kubectl\ get*) printf 'Kubernetes kaynaklarini listeler.' ;;
    kubectl\ apply*) printf 'Manifest degisikliklerini uygular.' ;;
    kubectl\ logs*) printf 'Pod loglarini gosterir.' ;;
    python*|python3*|py\ *) printf 'Python komutunu calistirir.' ;;
    pip\ install*|pip3\ install*) printf 'Python paketi kurar.' ;;
    uv\ run*) printf 'Komutu uv ortaminda calistirir.' ;;
    uv\ sync*) printf 'Python bagimliliklarini senkronlar.' ;;
    cargo\ run*) printf 'Rust uygulamasini calistirir.' ;;
    cargo\ build*) printf 'Rust projesini derler.' ;;
    cargo\ test*) printf 'Rust testlerini calistirir.' ;;
    go\ run*) printf 'Go kodunu calistirir.' ;;
    go\ build*) printf 'Go binary dosyasi uretir.' ;;
    go\ test*) printf 'Go testlerini calistirir.' ;;
    dotnet\ run*) printf '.NET uygulamasini calistirir.' ;;
    dotnet\ build*) printf '.NET projesini derler.' ;;
    dotnet\ test*) printf '.NET testlerini calistirir.' ;;
    code*) printf 'Editoru acar.' ;;
    ssh*) printf 'Uzak sunucuya baglanir.' ;;
    scp*|rsync*) printf 'Dosya aktarimi yapar.' ;;
    curl*|wget*) printf 'Veri indirir veya istek atar.' ;;
    systemctl*) printf 'Servisleri yonetir.' ;;
    journalctl*) printf 'Sistem loglarini gosterir.' ;;
    cd*) printf 'Klasor degistirir.' ;;
    ls*|ll*|dir*) printf 'Klasor icerigini listeler.' ;;
    mkdir*|md*) printf 'Yeni klasor olusturur.' ;;
    rm*|del*|erase*) printf 'Dosya veya klasor siler.' ;;
    cp*|copy*) printf 'Dosya kopyalar.' ;;
    mv*|move*|ren*|rename*) printf 'Dosya veya klasoru tasir.' ;;
    htop*|top*) printf 'Canli sistem kullanimini gosterir.' ;;
    pwsh*|powershell*) printf 'PowerShell komutu calistirir.' ;;
    *)
      printf "'%s' komutunu calistirir." "$(printf '%s' "${command}" | awk '{print $1}')"
      ;;
  esac
}

systemcmd_update_history_preview() {
  {
    printf 'Favoriler\n\n'
    if (($# == 0)); then
      printf 'Henuz favori yok.\n'
      return
    fi

    local index=1
    local line
    local summary
    for line in "$@"; do
      line="${line//$'\t'/ }"
      line="${line//$'\n'/ <nl> }"
      summary="$(systemcmd_history_summary "${line}")"
      if ((${#line} > 76)); then
        line="${line:0:76}..."
      fi
      printf '[%02d] %s :: %s\n' "${index}" "${line}" "${summary}"
      ((index++))
    done
  } > "${SYSTEMCMD_HISTORY_PREVIEW_PATH}"
}

systemcmd_is_favorite() {
  local command="$1"
  shift
  local item
  for item in "$@"; do
    [[ "${item}" == "${command}" ]] && return 0
  done
  return 1
}

systemcmd_toggle_favorite() {
  local command="$1"
  shift
  local -a favorites=("$@")
  local -a updated=()
  local item
  local found=0

  for item in "${favorites[@]}"; do
    if [[ "${item}" == "${command}" ]]; then
      found=1
      continue
    fi
    updated+=("${item}")
  done

  if (( found == 0 )); then
    updated=("${command}" "${updated[@]}")
  fi

  systemcmd_save_favorites "${updated[@]}"
}

systemcmd_fallback_help() {
  cat <<'EOF'
systemcmd

  systemcmd             : ana menuyu acar
  systemcmd doctor      : kurulum ve arac sagligini kontrol eder
  systemcmd theme build : tema dosyalarini yeniden uretir
  Ctrl+f                : hizli dosya secici
  Ctrl+r                : favorili gecmis aramasi, F ile yildizla
  ll                    : gizli dosyalarla listele
EOF
}

systemcmd_doctor_line() {
  local label="$1"
  local healthy="$2"
  local detail="$3"

  if [[ "${healthy}" == '1' ]]; then
    printf '\033[32mOK  \033[0m %-16s %s\n' "${label}" "${detail}"
  else
    printf '\033[33mWARN\033[0m %-16s %s\n' "${label}" "${detail}"
  fi
}

systemcmd_doctor() {
  local ok_count=0
  local warn_count=0
  local nvim_config="${HOME}/.config/nvim/init.lua"
  local bashrc_config="${HOME}/.config/systemcmd/systemcmd.bashrc"
  local theme_runtime="${HOME}/.config/systemcmd/systemcmd-theme.generated.sh"

  printf '\nsystemcmd doctor\n\n'

  if command -v fzf >/dev/null 2>&1; then
    systemcmd_doctor_line 'fzf' '1' "$(command -v fzf)"
    ((ok_count++))
  else
    systemcmd_doctor_line 'fzf' '0' 'Bulunamadi'
    ((warn_count++))
  fi

  if command -v bat >/dev/null 2>&1; then
    systemcmd_doctor_line 'bat' '1' "$(command -v bat)"
    ((ok_count++))
  elif command -v batcat >/dev/null 2>&1; then
    systemcmd_doctor_line 'bat' '1' "$(command -v batcat)"
    ((ok_count++))
  else
    systemcmd_doctor_line 'bat' '0' 'Bulunamadi'
    ((warn_count++))
  fi

  if command -v nvim >/dev/null 2>&1; then
    systemcmd_doctor_line 'Neovim' '1' "$(command -v nvim)"
    ((ok_count++))
  else
    systemcmd_doctor_line 'Neovim' '0' 'Bulunamadi'
    ((warn_count++))
  fi

  if [[ -f "${bashrc_config}" ]]; then
    systemcmd_doctor_line 'bashrc profile' '1' "${bashrc_config}"
    ((ok_count++))
  else
    systemcmd_doctor_line 'bashrc profile' '0' "${bashrc_config}"
    ((warn_count++))
  fi

  if [[ -f "${theme_runtime}" ]]; then
    systemcmd_doctor_line 'theme runtime' '1' "${theme_runtime}"
    ((ok_count++))
  else
    systemcmd_doctor_line 'theme runtime' '0' "${theme_runtime}"
    ((warn_count++))
  fi

  if [[ -f "${nvim_config}" ]]; then
    systemcmd_doctor_line 'Neovim config' '1' "${nvim_config}"
    ((ok_count++))
  else
    systemcmd_doctor_line 'Neovim config' '0' "${nvim_config}"
    ((warn_count++))
  fi

  if command -v xclip >/dev/null 2>&1 || command -v wl-copy >/dev/null 2>&1; then
    systemcmd_doctor_line 'clipboard' '1' "$(command -v wl-copy 2>/dev/null || command -v xclip 2>/dev/null)"
    ((ok_count++))
  else
    systemcmd_doctor_line 'clipboard' '0' 'xclip veya wl-clipboard yok'
    ((warn_count++))
  fi

  printf '\nToplam: %s OK, %s WARN\n' "${ok_count}" "${warn_count}"
}

systemcmd_doctor_summary() {
  local ok_count=0
  local warn_count=0

  command -v fzf >/dev/null 2>&1 && ((ok_count++)) || ((warn_count++))
  (command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1) && ((ok_count++)) || ((warn_count++))
  command -v nvim >/dev/null 2>&1 && ((ok_count++)) || ((warn_count++))
  [[ -f "${HOME}/.config/systemcmd/systemcmd-theme.generated.sh" ]] && ((ok_count++)) || ((warn_count++))
  [[ -f "${HOME}/.config/nvim/init.lua" ]] && ((ok_count++)) || ((warn_count++))

  printf '%s\t%s\n' "${ok_count}" "${warn_count}"
}

systemcmd_has_theme_builder() {
  command -v pwsh >/dev/null 2>&1 && [[ -f "${SYSTEMCMD_HOME}/theme/Build-SystemCmdTheme.ps1" ]]
}

systemcmd_menu() {
  if ! command -v fzf >/dev/null 2>&1; then
    systemcmd_fallback_help
    return
  fi

  local selection action summary ok_count warn_count
  local -a items
  IFS=$'\t' read -r ok_count warn_count < <(systemcmd_doctor_summary)
  summary="Enter: calistir | Esc: cik"$'\n'"Ctrl+f: dosya | Ctrl+r: history | doctor: ${ok_count} ok / ${warn_count} warn"
  items=(
$'core\tdoctor\tKurulum ve arac sagligini kontrol eder\t\033[38;5;36m[CORE]\033[0m \033[97mdoctor     \033[0m \033[38;5;245mKurulum ve arac sagligini kontrol eder\033[0m'
$'tools\tports\tAcik portlari listeler\t\033[38;5;214m[TOOLS]\033[0m \033[97mports      \033[0m \033[38;5;245mAcik portlari listeler\033[0m'
$'editor\tnvim\tNeovim acilir\t\033[38;5;45m[EDITOR]\033[0m \033[97mnvim       \033[0m \033[38;5;245mNeovim acilir\033[0m'
$'shell\tll\tGizli dosyalarla listeleme yapar\t\033[38;5;39m[SHELL]\033[0m \033[97mll         \033[0m \033[38;5;245mGizli dosyalarla listeleme yapar\033[0m'
  )

  if systemcmd_has_theme_builder; then
    items+=($'theme\ttheme build\tTek kaynak paletten tema dosyalarini uretir\t\033[38;5;171m[THEME]\033[0m \033[97mtheme build\033[0m \033[38;5;245mTek kaynak paletten tema dosyalarini uretir\033[0m')
  fi

  selection="$(
    printf '%s\n' "${items[@]}" | fzf --layout reverse --border --delimiter $'\t' --with-nth 4 --nth 1,2,3,4 --prompt 'systemcmd > ' --header "${summary}" --ansi --color "${SYSTEMCMD_FZF_COLOR}"
  )" || return

  action="$(printf '%s\n' "${selection}" | awk -F '\t' '{print $2}')"

  case "${action}" in
    doctor) systemcmd_doctor ;;
    ports) ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || printf 'Port araci bulunamadi.\n' ;;
    nvim) command -v nvim >/dev/null 2>&1 && nvim || printf 'nvim bulunamadi.\n' ;;
    'theme build') pwsh -NoLogo -NoProfile -File "${SYSTEMCMD_HOME}/theme/Build-SystemCmdTheme.ps1" ;;
    ll) ll ;;
  esac
}

systemcmd() {
  local command="${1:-menu}"
  local subcommand="${2:-}"
  shift || true

  case "${command}" in
    help) systemcmd_menu ;;
    doctor) systemcmd_doctor ;;
    menu) systemcmd_menu ;;
    theme)
      case "${subcommand}" in
        build)
          if systemcmd_has_theme_builder; then
            pwsh -NoLogo -NoProfile -File "${SYSTEMCMD_HOME}/theme/Build-SystemCmdTheme.ps1"
          else
            printf 'theme build script bulunamadi.\n'
          fi
          ;;
        *)
          printf 'Kullanim: systemcmd theme build\n'
          ;;
      esac
      ;;
    *)
      systemcmd_menu
      ;;
  esac
}

alias system='systemcmd'

systemcmd_file_widget() {
  if ! command -v fzf >/dev/null 2>&1; then
    return
  fi

  local left right token root initial_query directory_mode selected_file
  IFS=$'\t' read -r left right token < <(systemcmd_current_token_bounds)

  root="${PWD}"
  initial_query="${token}"
  directory_mode='0'

  if resolved_root="$(systemcmd_resolve_dir_token "${token}")"; then
    root="${resolved_root}"
    initial_query=''
    directory_mode='1'
  fi

  selected_file="$(systemcmd_run_file_picker "${root}" "${initial_query}" "${directory_mode}")" || return
  [[ -z "${selected_file}" ]] && return

  systemcmd_replace_current_token "$(systemcmd_quote_path "${selected_file}")"
}

systemcmd_history_widget() {
  if ! command -v fzf >/dev/null 2>&1; then
    return
  fi

  local query output pressed selected_line encoded_command selected_command
  local entry item marker id display payload is_favorite
  local -a history_entries favorites ordered items output_lines history_fzf_args

  mapfile -t history_entries < <(systemcmd_get_history_entries)
  mapfile -t favorites < <(systemcmd_get_favorites)
  [[ ${#history_entries[@]} -eq 0 ]] && return

  query="${READLINE_LINE}"

  while :; do
    ordered=()
    for item in "${favorites[@]}"; do
      for entry in "${history_entries[@]}"; do
        if [[ "${entry}" == "${item}" ]]; then
          ordered+=("${entry}")
          break
        fi
      done
    done

    for entry in "${history_entries[@]}"; do
      if ! systemcmd_is_favorite "${entry}" "${favorites[@]}"; then
        ordered+=("${entry}")
      fi
    done

    items=()
    id=1
    for entry in "${ordered[@]}"; do
      is_favorite='0'
      marker=' '
      display="${entry//$'\t'/ }"
      display="${display//$'\n'/ <nl> }"
      if ((${#display} > 220)); then
        display="${display:0:220}..."
      fi

      if systemcmd_is_favorite "${entry}" "${favorites[@]}"; then
        is_favorite='1'
        marker=$'\033[38;5;214m*\033[0m'
        display="$(printf '\033[38;5;214m%s\033[0m' "${display}")"
      fi

      payload="$(printf '%s' "${entry}" | base64 | tr -d '\n')"
      items+=("$(printf '%b \033[38;5;245m[%04d]\033[0m %b\t%s\t%s' "${marker}" "${id}" "${display}" "${is_favorite}" "${payload}")")
      ((id++))
    done

    systemcmd_update_history_preview "${favorites[@]}"
    history_fzf_args=(
      --ansi
      --layout reverse
      --border
      --cycle
      --delimiter $'\t'
      --with-nth 1
      --nth 1
      --print-query
      --expect f
      --prompt 'history > '
      --header 'F: favori ac/kapat'
      --bind 'ctrl-r:toggle-sort'
      --preview "cat '${SYSTEMCMD_HISTORY_PREVIEW_PATH}'"
      --preview-window 'right,50%,wrap,border-left'
      --color "${SYSTEMCMD_FZF_COLOR}"
    )

    if [[ -n "${query}" ]]; then
      history_fzf_args+=(--query "${query}")
    fi

    output="$(
      printf '%s\n' "${items[@]}" |
      fzf "${history_fzf_args[@]}"
    )" || return

    mapfile -t output_lines <<< "${output}"
    query="${output_lines[0]}"
    pressed="${output_lines[1]}"
    selected_line="${output_lines[2]}"
    [[ -z "${selected_line}" ]] && return

    encoded_command="$(printf '%s' "${selected_line}" | awk -F '\t' '{print $3}')"
    selected_command="$(printf '%s' "${encoded_command}" | base64 --decode 2>/dev/null)"
    [[ -z "${selected_command}" ]] && return

    if [[ "${pressed}" == 'f' ]]; then
      systemcmd_toggle_favorite "${selected_command}" "${favorites[@]}"
      mapfile -t favorites < <(systemcmd_get_favorites)
      continue
    fi

    READLINE_LINE="${selected_command}"
    READLINE_POINT=${#READLINE_LINE}
    return
  done
}

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  # shellcheck disable=SC1091
  . /usr/share/bash-completion/bash_completion
fi

if command -v bind >/dev/null 2>&1; then
  bind -x '"\C-f":systemcmd_file_widget'
  bind -x '"\C-r":systemcmd_history_widget'
fi

PS1='\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;36m\]\w\[\033[00m\] \$ '
