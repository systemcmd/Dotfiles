# Source this bridge from bash. No prompt hook or process is run at shell startup.
_SYSTEMCMD_BRIDGE_ROOT="$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
systemcmd() {
    if ! command -v pwsh >/dev/null 2>&1; then
        printf '%s\n' 'SYSTEMCMD requires PowerShell 7 (pwsh).' >&2
        return 127
    fi
    command pwsh -NoLogo -NoProfile -File "${_SYSTEMCMD_BRIDGE_ROOT}/shell/Invoke-SystemCmd.ps1" "$@"
}
sc() { systemcmd "$@"; }
