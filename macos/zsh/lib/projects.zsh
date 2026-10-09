# Projeler: tur algilama, Ctrl+P proje atlama, sc run gorevleri, sc env

typeset -g SYSTEMCMD_PROJECT_DIRS="${SYSTEMCMD_PROJECT_DIRS:-$HOME/Desktop:$HOME/Developer:$HOME/Projects:$HOME/code:$HOME/src}"
typeset -g _SC_PROJECT_ROOT="" _SC_PROJECT_TYPE="" _SC_ENV_LOADED=""
typeset -ga _SC_ENV_KEYS

# Klasorden yukari cikarak proje kokunu ve turunu bulur
_sc_detect_project() {
  local dir="$PWD" type=""
  while [[ "$dir" != "/" && "$dir" != "$HOME" && -n "$dir" ]]; do
    if   [[ -f "$dir/pubspec.yaml" ]]; then
      if grep -q 'sdk: flutter' "$dir/pubspec.yaml" 2>/dev/null; then type=flutter; else type=dart; fi
    elif [[ -f "$dir/package.json" ]]; then type=node
    elif [[ -f "$dir/Cargo.toml" ]]; then type=rust
    elif [[ -f "$dir/go.mod" ]]; then type=go
    elif [[ -f "$dir/pyproject.toml" || -f "$dir/requirements.txt" || -f "$dir/setup.py" ]]; then type=python
    elif [[ -f "$dir/Package.swift" || -n "$dir"/*.xcodeproj(#qN[1]) ]]; then type=swift
    elif [[ -f "$dir/build.gradle" || -f "$dir/build.gradle.kts" ]]; then type=android
    elif [[ -n "$dir"/*.(csproj|sln)(#qN[1]) ]]; then type=dotnet
    elif [[ -f "$dir/docker-compose.yml" || -f "$dir/compose.yaml" || -f "$dir/Dockerfile" ]]; then type=docker
    elif [[ -d "$dir/.git" ]]; then type=""
    else dir="${dir:h}"; continue
    fi
    break
  done
  [[ "$dir" == "/" || "$dir" == "$HOME" ]] && dir=""

  local prev="$_SC_PROJECT_ROOT"
  _SC_PROJECT_ROOT="$dir"
  _SC_PROJECT_TYPE="$type"

  # Projeden cikinca yuklenen .env degiskenlerini geri al
  if [[ -n "$_SC_ENV_LOADED" && "$_SC_ENV_LOADED" != "$dir" ]]; then
    sc_env_unload quiet
  fi

  # Yeni projeye girildiyse tek satir ipucu
  if [[ -n "$dir" && "$dir" != "$prev" ]]; then
    local hint="%F{${SC_COLOR[muted]}}  ${SC_ICON[$type]:-${SC_ICON[dir]}} ${dir:t}"
    [[ -n "$type" ]] && hint+=" · $type"
    hint+=" · %F{${SC_COLOR[cyan]}}sc run%F{${SC_COLOR[muted]}} gorevler"
    [[ -f "$dir/.env" ]] && hint+=" · %F{${SC_COLOR[yellow]}}sc env%F{${SC_COLOR[muted]}} .env yukle"
    print -P "${hint}%f"
  fi
}

add-zsh-hook chpwd _sc_detect_project
_sc_detect_project >/dev/null

# --- .env: sadece KEY=VALUE satirlarini okur, kod calistirmaz -----------------
sc_env() {
  local root="${_SC_PROJECT_ROOT:-$PWD}" file="${1:-}"
  [[ -z "$file" ]] && file="$root/.env"
  [[ -r "$file" ]] || { print -P "%F{${SC_COLOR[red]}}.env bulunamadi:%f $file"; return 1; }
  [[ -n "$_SC_ENV_LOADED" ]] && sc_env_unload quiet

  local line key val n=0
  _SC_ENV_KEYS=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line##[[:space:]]#}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    line="${line#export }"
    key="${line%%=*}"
    [[ "$key" == [A-Za-z_][A-Za-z0-9_]# && "$line" == *=* ]] || continue
    val="${line#*=}"
    if [[ "$val" == \"*\" || "$val" == \'*\' ]]; then
      val="${val[2,-2]}"
    else
      val="${val%%[[:space:]]#\#*}"
    fi
    # Onceki degeri sakla ki cikarken geri koyalim
    typeset -g "_SC_ENV_PREV_$key=${(P)key-__sc_unset__}"
    export "$key=$val"
    _SC_ENV_KEYS+=("$key")
    (( n++ ))
  done < "$file"
  _SC_ENV_LOADED="$root"
  print -P "%F{${SC_COLOR[green]}}.env yuklendi:%f $n degisken %F{${SC_COLOR[muted]}}(${(j:, :)_SC_ENV_KEYS})%f"
}

sc_env_unload() {
  local key prev_var
  for key in "${_SC_ENV_KEYS[@]}"; do
    prev_var="_SC_ENV_PREV_$key"
    if [[ "${(P)prev_var}" == __sc_unset__ ]]; then unset "$key"; else export "$key=${(P)prev_var}"; fi
    unset "$prev_var"
  done
  [[ "$1" == quiet ]] || print -P "%F{${SC_COLOR[muted]}}.env kaldirildi (${#_SC_ENV_KEYS} degisken)%f"
  _SC_ENV_KEYS=()
  _SC_ENV_LOADED=""
}

# --- sc run: projeye gore gorev menusu ---------------------------------------
_sc_project_tasks() {
  local root="${_SC_PROJECT_ROOT:-$PWD}"
  local -a t
  case "$_SC_PROJECT_TYPE" in
    flutter)
      t=('flutter run' 'flutter run -d ios' 'flutter run -d android' 'flutter run --release'
         'flutter pub get' 'flutter pub upgrade' 'flutter pub outdated' 'flutter analyze' 'flutter test'
         'flutter clean && flutter pub get' 'flutter build apk --release' 'flutter build appbundle --release'
         'flutter build ipa --release' 'flutter devices' 'flutter doctor -v'
         'dart run build_runner build --delete-conflicting-outputs' 'dart format .'
         'cd ios && pod install && cd ..' 'open ios/Runner.xcworkspace') ;;
    dart) t=('dart run' 'dart test' 'dart pub get' 'dart analyze' 'dart format .') ;;
    rust) t=('cargo run' 'cargo build --release' 'cargo test' 'cargo clippy' 'cargo fmt' 'cargo update') ;;
    go) t=('go run .' 'go build ./...' 'go test ./...' 'go vet ./...' 'go mod tidy') ;;
    python)
      [[ -f "$root/pyproject.toml" ]] && command -v uv >/dev/null && t+=('uv sync' 'uv run python' 'uv run pytest')
      t+=('python3 -m venv .venv && source .venv/bin/activate' 'source .venv/bin/activate' 'pip install -r requirements.txt' 'pytest') ;;
    swift) t=('swift build' 'swift test' 'swift run' 'xcodebuild -list' 'open -a Xcode .') ;;
    android) t=('./gradlew assembleDebug' './gradlew test' './gradlew clean' './gradlew tasks') ;;
    dotnet) t=('dotnet run' 'dotnet build' 'dotnet test' 'dotnet restore' 'dotnet watch') ;;
    docker) t=('docker compose up -d' 'docker compose down' 'docker compose logs -f' 'docker compose ps' 'docker compose build') ;;
  esac
  if [[ -f "$root/package.json" ]] && command -v node >/dev/null; then
    local pm=npm
    [[ -f "$root/pnpm-lock.yaml" ]] && pm=pnpm
    [[ -f "$root/yarn.lock" ]] && pm=yarn
    [[ -f "$root/bun.lockb" || -f "$root/bun.lock" ]] && pm=bun
    local s
    for s in ${(f)"$(node -e 'try{const p=require(process.argv[1]);for(const k of Object.keys(p.scripts||{}))console.log(k)}catch(e){}' "$root/package.json" 2>/dev/null)"}; do
      t+=("$pm run $s")
    done
    t+=("$pm install")
  fi
  if [[ -f "$root/Makefile" ]]; then
    local m
    for m in ${(f)"$(grep -oE '^[a-zA-Z0-9_.-]+:' "$root/Makefile" | tr -d ':' | sort -u)"}; do t+=("make $m"); done
  fi
  [[ -f "$root/docker-compose.yml" || -f "$root/compose.yaml" ]] && [[ "$_SC_PROJECT_TYPE" != docker ]] && t+=('docker compose up -d' 'docker compose down')
  [[ -d "$root/.git" ]] && t+=('lazygit' 'git pull --rebase' 'git push')
  print -rl -- "${t[@]}"
}

sc_run() {
  local tasks
  tasks="$(_sc_project_tasks)"
  if [[ -z "$tasks" ]]; then
    print -P "%F{${SC_COLOR[muted]}}Bu klasor icin gorev bulunamadi.%f"
    return 1
  fi
  local pick
  pick="$(print -r -- "$tasks" | fzf --height=60% --prompt="${_SC_PROJECT_TYPE:-proje} > " \
          --border-label=" ${${_SC_PROJECT_ROOT:-$PWD}:t} " --header='Enter: satira yaz (sonra Enter ile calistir)')" || return
  # Proje kokunde degilsek once oraya gec
  if [[ -n "$_SC_PROJECT_ROOT" && "$PWD" != "$_SC_PROJECT_ROOT" ]]; then
    pick="cd ${(q-)_SC_PROJECT_ROOT} && $pick"
  fi
  print -z -- "$pick"
}

# --- Ctrl+P: proje atlama ------------------------------------------------------
_sc_list_projects() {
  local d
  for d in ${(s.:.)SYSTEMCMD_PROJECT_DIRS}; do
    [[ -d "$d" ]] || continue
    if command -v fd >/dev/null; then
      fd --hidden --no-ignore --type d --max-depth 4 '^\.git$' "$d" --exclude node_modules --exclude Pods 2>/dev/null | sed 's#/\.git/*$##'
    else
      find "$d" -maxdepth 4 -type d -name .git -not -path '*/node_modules/*' 2>/dev/null | sed 's#/\.git$##'
    fi
  done
  command -v zoxide >/dev/null && zoxide query -l 2>/dev/null | head -50
}

sc-project-widget() {
  command -v fzf >/dev/null || { zle -M 'fzf bulunamadi'; return 1; }
  local pick
  pick="$(_sc_list_projects | awk '!seen[$0]++' | sed "s#^$HOME#~#" |
    fzf --height=80% --prompt='proje > ' --border-label=' systemcmd projeler ' \
        --header='Enter: klasore gec | SYSTEMCMD_PROJECT_DIRS ile klasor ekle' \
        --preview="d=\$(echo {} | sed \"s#^~#\$HOME#\"); git -C \"\$d\" log --color=always --format='%C(yellow)%h%Creset %s %C(241)%ar' -n 8 2>/dev/null; echo; $SC_PREVIEW_DIR \"\$d\" 2>/dev/null | head -40" \
        --preview-window='right,55%,border-left')" || { zle reset-prompt; return 0; }
  pick="${pick/#\~/$HOME}"
  BUFFER="cd ${(q-)pick}"
  zle reset-prompt
  zle accept-line
}

zle -N sc-project-widget
bindkey '^P' sc-project-widget
