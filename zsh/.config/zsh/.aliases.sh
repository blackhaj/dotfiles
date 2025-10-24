#!/bin/zsh

alias code="cursor"

# Git
alias gcmp="git checkout main && git pull"
alias gco='git checkout'
alias gcob='gco -b'
alias gdall="git branch | grep -v ' main$' | xargs git branch -d"
alias gdmb="git fetch -p && ! git branch --merged origin/main | egrep -v '(^\\*|main)' | xargs git branch -d"
alias gpf="git push --force-with-lease"
alias grc='git rebase --continue'
alias gs='git status'
alias gsco="stash-then-checkout"
alias gstr="git stash -u && git rebase main && git stash pop"
alias prm='$HOME/scripts/pr-post/pr-post.sh'
alias pti='git pull;mono;pnpm install'
alias "??"="gh copilot suggest -t shell"
alias gsu="git stash -u"
alias gsp="git stash pop"

#Navigation
## Personal
alias cod="cd ~/code"
alias dump="cd ~/code/bin"
alias bin="cd ~/code/bin"
alias hub="cd ~/code/hub"
alias mega="cd ~/code/hub/apps/mega"
alias site="cd ~/code/hub/apps/website"
alias ui="cd ~/code/hub/packages/ui"

alias dots="code $HOME/dotfiles"

## Work
alias maze="cd ~/maze"
alias maz="cd ~/maze"
alias api="cd ~/maze/maze-monorepo/packages/maze-api"
alias core="cd ~/maze/maze-monorepo/packages/maze-api-core"
alias lams="cd ~/maze/maze-monorepo/lambdas"
alias mono="cd ~/maze/maze-monorepo"
alias mod="cd ~/maze/maze-monorepo/services/service-moderated-testing"
alias omono="code -r ~/maze/maze-monorepo"
alias omod="code -r ~/maze/maze-monorepo/services/service-moderated-testing"
alias oterra="code ~/maze/maze-monorepo-terraform"
# alias test="cd ~/maze/maze-monorepo/packages/maze-test-suite"
alias track="cd ~/maze/maze-monorepo/services/maze-tracking"
alias res="cd ~/maze/maze-monorepo/services/results-api"
alias web="cd ~/maze/maze-monorepo/apps/maze-webapp"
alias kn="killall node"
alias tu="tilt up"
# Finds circular dependencies
alias fcd="pnpx madge -c --extensions js,jsx,ts,tsx ./src/"
# Refresh Graph Gateway Schema
alias ggr="curl http://localhost:3005/hot-schemas-reload"

# NPM
alias nd='npm run dev'
alias ni='npm install'

# Yarn
alias y='yarn'
alias yd='yarn dev'
alias yi='yarn install'
alias ysw='yarn serve:watch'
alias ytd='yarn install;yarn dev'
alias ydt='IS_ACCEPTANCE_TEST=true yarn dev'
alias ysl='yarn serve -- --stage testing'

# PNPM
alias p="pnpm"
alias pd='pnpm dev'
alias pdl='pnpm dev -H $(ipconfig getifaddr en0)'
alias pi='pnpm install'
alias pb='pnpm bootstrap'
alias px="pnpm exec"
alias psw='pnpm serve:watch'
alias ptd='pnpm bootstrap && pnpm dev'
alias ptt='pnpm bootstrap && tilt up'
alias btd='pnpm bootstrap && tilt up'
alias pdt='IS_ACCEPTANCE_TEST=true pnpm dev'
alias psl='pnpm serve -- --stage testing'

# General
alias ls='eza --group-directories-first --icons -a -x --hyperlink'
alias cat='bat'
