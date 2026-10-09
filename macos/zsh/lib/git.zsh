# Ctrl+G: git gezgini
#   Ctrl+G dosyalar (degisenler, diff onizleme)
#   Ctrl+B branch'ler (log onizleme)
#   Ctrl+L commit'ler (show onizleme)
#   Ctrl+T stash'ler
#   Enter  secimi satira yazar; satir bossa: branch -> git switch, dosya -> git add

_sc_git_list() {
  case "$1" in
    files)
      git -c color.status=always status --short --untracked-files=all 2>/dev/null |
        awk '{ path=$NF; print "F\t" path "\t" $0 }' ;;
    branches)
      git for-each-ref --sort=-committerdate refs/heads refs/remotes \
        --format=$'B\t%(refname:short)\t%(HEAD) %(color:green)%(refname:short)%(color:reset) %(color:241)%(committerdate:relative) · %(subject)%(color:reset)' \
        --color=always 2>/dev/null | grep -v $'\torigin/HEAD\t' ;;
    commits)
      git log --color=always --format=$'C\t%h\t%C(yellow)%h%Creset %C(241)%ad%Creset %s %C(magenta)%an%Creset%C(auto)%d' \
        --date=short -n 300 2>/dev/null ;;
    stash)
      git stash list --format=$'S\t%gd\t%C(yellow)%gd%Creset %s' --color=always 2>/dev/null ;;
  esac
}

sc-git-widget() {
  command -v fzf >/dev/null || { zle -M 'fzf bulunamadi'; return 1; }
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    zle -M 'Burasi bir git deposu degil.'
    return 0
  fi

  local self="source ${(q)SYSTEMCMD_ROOT}/lib/git.zsh; _sc_git_list"
  local diffpager='cat'
  command -v delta >/dev/null && diffpager="delta --paging=never --width=\$FZF_PREVIEW_COLUMNS"
  local preview="case {1} in
    F) if git ls-files --error-unmatch {2} >/dev/null 2>&1; then git diff --color=always HEAD -- {2} | $diffpager; else ${SC_PREVIEW_FILE} {2}; fi ;;
    B) git log --graph --color=always --format='%C(yellow)%h%Creset %s %C(241)%ar%Creset' -n 40 {2} ;;
    C) git show --stat --patch --color=always {2} | $diffpager ;;
    S) git stash show --patch --color=always {2} | $diffpager ;;
  esac"

  local sel
  sel="$(_sc_git_list files | fzf --ansi --height=80% \
      --delimiter=$'\t' --with-nth=3 \
      --prompt='git dosyalar > ' --border-label=' systemcmd git ' \
      --header='Ctrl+G dosyalar | Ctrl+B branch | Ctrl+L commit | Ctrl+T stash | Ctrl+/ onizleme' \
      --preview="$preview" --preview-window='right,60%,border-left' \
      --bind='ctrl-/:toggle-preview' \
      --bind="ctrl-g:reload(zsh -c '$self files')+change-prompt(git dosyalar > )" \
      --bind="ctrl-b:reload(zsh -c '$self branches')+change-prompt(git branch > )" \
      --bind="ctrl-l:reload(zsh -c '$self commits')+change-prompt(git commit > )" \
      --bind="ctrl-t:reload(zsh -c '$self stash')+change-prompt(git stash > )"
  )" || { zle reset-prompt; return 0; }

  local kind="${sel%%$'\t'*}" value="${${sel#*$'\t'}%%$'\t'*}"
  if [[ -z "$BUFFER" ]]; then
    case "$kind" in
      B) value="${value#origin/}"; BUFFER="git switch ${(q-)value}" ;;
      F) BUFFER="git add -- ${(q-)value}" ;;
      C) BUFFER="git show ${value}" ;;
      S) BUFFER="git stash apply ${value}" ;;
    esac
  else
    LBUFFER+="${(q-)value}"
  fi
  CURSOR=${#BUFFER}
  zle reset-prompt
}

zle -N sc-git-widget
bindkey '^G' sc-git-widget
