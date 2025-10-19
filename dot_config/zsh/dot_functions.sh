#!/bin/zsh
# shellcheck shell=bash

# Fuzzy Git Checkout. Source: https://polothy.github.io/post/2019-08-19-fzf-git-checkout/
fuzzy-find-branch() {
  git rev-parse HEAD >/dev/null 2>&1 || return

  git branch --color=always --sort=-committerdate |
    grep -v HEAD |
    fzf --height 50% --ansi --no-multi |
    sed "s/.* //"
}

copy-branch() {
  branch=$(fuzzy-find-branch)

  print -s "$branch"
  echo "$branch" | pbcopy
}

alias ggb=copy-branch

checkout-branch() {
  branch=$(fuzzy-find-branch)

  print -s "git checkout $branch"
  git checkout "$branch"
}

alias gcof=checkout-branch

delete-branch() {
  branch=$(fuzzy-find-branch)

  print -s "git branch -d $branch"
  git branch -d "$branch"
}

alias gdf=delete-branch

delete-branch-force() {
  branch=$(fuzzy-find-branch)

  print -s "git branch -D $branch"
  git branch -D "$branch"
}

alias gDf=delete-branch-force

use-scripts() {
  if [[ -f pnpm-lock.json ]]; then
    packageManager="pnpm"
  elif [[ -f package-lock.json ]]; then
    packageManager="npm"
  elif [[ -f bun.lock ]]; then
    packageManager="bun"
  elif [[ -f yarn.lock ]]; then
    packageManager="yarn"
  fi

  sc=$(cat package.json | jq '.scripts | keys[]' | tr -d '\"' | fzf)

  if [[ $? = 0 ]]; then
    print -s "$packageManager run $sc"
    $packageManager run "$sc"
  fi
}

alias sc='use-scripts'

nuke_pnpm() {
  rm -rf ~/.pnpm-store && pnpm -r exec rm -rf node_modules build dist lib && rm -rf node_modules apps/maze-webapp/public/ && pnpm i && say 'ready'
}

pritunl() {
  client() {
    # change this to point to your Pritunl.app if this is not the right path
    /Applications/Pritunl.app/Contents/Resources/pritunl-client "$@"
  }
  # you can find the profile id by running `pritunl list`
  profileId="y5sanivernfd94nc"

  if [[ $1 == 'start' ]]; then
    # set the "Pritunl" here to whatever you have your Pritunl under in 1pass
    otp=$(op item get Pritunl --otp)
    client start $profileId -p "$otp"
  elif [[ $1 == 'stop' ]]; then
    client stop $profileId
  else
    client "$@"
  fi
}

alias pts='pritunl start'
alias ptst='pritunl stop'
alias ptr='pritunl stop && pritunl start'

change_ts_hint_length() {
  # Add your VScode path here
  directory_path="/Applications/Visual Studio Code.app"
  new_length="$1"

  if [ -z "$1" ]; then
    echo "No length supplied, will use default (160)"
    new_length=160
  fi

  file_path=$(find "$directory_path" -name "tsserver.js" 2>/dev/null)
  if [ -z "$file_path" ]; then
    echo "tsserver.js file not found within directory $directory_path after recursive search"
    exit 1
  fi

  # echo "Found tsserver.js at \"$file_path\""

  # Use awk to perform the replacement
  awk -v new_length="$new_length" '{sub(/var defaultMaximumTruncationLength = [0-9]+;/, "var defaultMaximumTruncationLength = " new_length ";")}1' "$file_path" >temp_file && mv temp_file "$file_path"

  echo "Length updated successfully: "
  cat "$file_path" | grep "defaultMaximumTruncationLength = "

}

alias tslen="change_ts_hint_length"

git_prune_squash_merged() {
  # Get a list of all current branches
  git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do
    # Get the merge-base between main and the current branch
    mergeBase=$(git merge-base origin/main "$branch")
    # Get the commit-tree for the current branch
    commitTree=$(git commit-tree $(git rev-parse "$branch^{tree}") -p "$mergeBase" -m _)
    # If the commit-tree is not empty, then the branch is not merged
    if [[ $(git cherry origin/main "$commitTree") == "-"* ]]; then
      # Delete the branch
      git branch -D "$branch"
    fi
  done
}

alias gsdall="git_prune_squash_merged"

open_moderated_and_run() {
  # Open VSCode with the repository
  code ~/maze/service-moderated-testing

  # Wait for VSCode to open and then run a command in the terminal
  sleep 5

  # Make sure VSCode is in focus
  osascript -e 'tell application "Visual Studio Code" to activate'
  # Open the integrated terminal
  osascript -e 'tell application "System Events" to keystroke "`Command` + `" to front window'
  # Type and execute your command
  osascript -e 'tell application "System Events" to keystroke "ptd"'
  # Press Enter to execute the command
  osascript -e 'tell application "System Events" to key code 36'

  return $?
}

alias op-mod="open_moderated_and_run"

open_mono_and_run() {
  # Open VSCode with the repository
  code ~/maze/maze-monorepo

  # Wait for VSCode to open and then run a command in the terminal
  sleep 5                                                                                      # Adjust the wait time as needed
  osascript -e 'tell application "Visual Studio Code" to activate'                             # Make sure VSCode is in focus
  osascript -e 'tell application "System Events" to keystroke "`Command` + `" to front window' # Open the integrated terminal
  osascript -e 'tell application "System Events" to keystroke "tu"'                            # Type and execute your command
  osascript -e 'tell application "System Events" to key code 36'                               # Press Enter to execute the command
  return $?
}

alias op-mono="open_mono_and_run"
