# Buddy: cross-platform companion. Gorseller systemcmd deposundaki pwsh
# motorundan gelir (Windows ile birebir), XP native/hizlidir.
# Depo yeri: $SYSTEMCMD_CORE  (systemcmd reposu — buddy PS dosyalari burada)

typeset -g SYSTEMCMD_CORE="${SYSTEMCMD_CORE:-}"
if [[ -z "$SYSTEMCMD_CORE" ]]; then
  for _d in \
    "$HOME/Desktop/systemcmd" \
    "$HOME/systemcmd" \
    "$HOME/.local/share/systemcmd-core" \
    "${SYSTEMCMD_ROOT:A:h:h}"; do
    if [[ -f "$_d/buddy-engine.ps1" ]]; then SYSTEMCMD_CORE="$_d"; break; fi
  done
  unset _d
fi

if [[ -n "$SYSTEMCMD_CORE" && -f "$SYSTEMCMD_CORE/shell/buddy.sh" ]]; then
  export SYSTEMCMD_BUDDY_HOME="$SYSTEMCMD_CORE"
  source "$SYSTEMCMD_CORE/shell/buddy.sh"
  typeset -g _SC_BUDDY_OK=1
else
  typeset -g _SC_BUDDY_OK=0
  buddy() {
    print -P "%F{${SC_COLOR[orange]}}Buddy deposu bulunamadi.%f"
    print -P "%F{${SC_COLOR[muted]}}systemcmd reposunu ~/Desktop/systemcmd altina klonla ya da%f"
    print -P "%F{${SC_COLOR[muted]}}export SYSTEMCMD_CORE=/yol/systemcmd ekle, sonra: reload%f"
  }
fi
