# Source this bridge from zsh. Share all behavior with the portable core.
_SYSTEMCMD_BRIDGE_ROOT="${${(%):-%N}:A:h:h}"
systemcmd() {
    if ! command -v pwsh >/dev/null 2>&1; then
        printf '%s\n' 'SYSTEMCMD requires PowerShell 7 (pwsh).' >&2
        return 127
    fi
    command pwsh -NoLogo -NoProfile -File "${_SYSTEMCMD_BRIDGE_ROOT}/shell/Invoke-SystemCmd.ps1" "$@"
}
sc() { systemcmd "$@"; }
