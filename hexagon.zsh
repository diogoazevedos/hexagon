# Hexagon
# Based on Geometry

GIT_DIRTY="%{$fg[red]%}⬡%{$reset_color%}"
GIT_CLEAN="%{$fg[green]%}⬢%{$reset_color%}"
GIT_REBASE="\uE0A0"
GIT_UNPULLED="⇣"
GIT_UNPUSHED="⇡"

ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[white]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"

hexagon_git_time_since_commit() {
  if [[ $(git log &> /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
    # Get the last commit.
    last_commit=$(git log --pretty=format:'%at' -1 2> /dev/null)
    now=$(date +%s)
    seconds_since_last_commit=$((now - last_commit))

    # Totals
    minutes=$((seconds_since_last_commit / 60))
    hours=$((seconds_since_last_commit / 3600))

    # Sub-hours and sub-minutes
    days=$((seconds_since_last_commit / 86400))
    sub_hours=$((hours % 24))
    sub_minutes=$((minutes % 60))

    if [ $hours -gt 24 ]; then
      commit_age="${days}d"
      color=$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG
    elif [ $minutes -gt 60 ]; then
      commit_age="${sub_hours}h${sub_minutes}m"
      color=$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL
    else
      commit_age="${minutes}m"
      color=$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT
    fi

    echo "$color$commit_age%{$reset_color%}"
  fi
}

hexagon_git_branch() {
  ref=$(git symbolic-ref --short HEAD 2> /dev/null) || \
  ref=$(git rev-parse --short HEAD 2> /dev/null) || return

  echo $ref
}

hexagon_git_dirty() {
  if test -z "$(git status --porcelain --ignore-submodules)"; then
    echo $GIT_CLEAN
  else
    echo $GIT_DIRTY
  fi
}

hexagon_git_rebase_check() {
  git_dir=$(git rev-parse --git-dir)

  if test -d "$git_dir/rebase-merge" -o -d "$git_dir/rebase-apply"; then
    echo $GIT_REBASE
  fi
}

hexagon_git_remote_check() {
  local_commit=$(git rev-parse @ 2>&1)
  remote_commit=$(git rev-parse @{u} 2>&1)
  common_base=$(git merge-base @ @{u} 2>&1) # last common commit

  if [[ $common_base == $remote_commit ]]; then
    echo $GIT_UNPUSHED
  elif [[ $common_base == $local_commit ]]; then
    echo $GIT_UNPULLED
  else
    echo $GIT_UNPUSHED $GIT_UNPULLED
  fi
}

hexagon_git_symbol() {
  echo "$(hexagon_git_rebase_check) $(hexagon_git_remote_check) "
}

hexagon_git_info() {
  if git rev-parse --git-dir &> /dev/null; then
    echo "$(hexagon_git_symbol)%F{242}$(hexagon_git_branch)%{$reset_color%} :: $(hexagon_git_time_since_commit) :: $(hexagon_git_dirty)"
  fi
}

hexagon_render() {
  PROMPT="%{$fg[blue]%}%2~%{$reset_color%} "
  RPROMPT="$(hexagon_git_info)"
}

hexagon_prompt() {
  autoload -U add-zsh-hook
  add-zsh-hook precmd hexagon_render
}

hexagon_prompt
