# Commands
alias ls='eza --group-directories-first --icons -a -x --hyperlink'
alias tree='eza --group-directories-first --icons -x --hyperlink -I node_modules -T'
alias cat='bat'
alias nid="bunx nanoid --alphabet 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwx
yz0123456789' --size"
alias code="cursor"

# Git
alias gco='git checkout'
alias gcob='gco -b'
alias gpf="git push --force-with-lease"
alias grc='git rebase --continue'
alias gs='git status'
alias gstr="git stash -u && git rebase main && git stash pop"
alias prm='$HOME/scripts/pr-post/pr-post.sh'

#Navigation
alias cod='cd $CODE_DIR'
alias dump='cd $CODE_DIR/dump'
alias dots='code $DOTFILES_DIR'
alias rfp='cd $CODE_DIR/rfp'
alias hcg='cd $CODE_DIR/hcg'
alias hv='cd $CODE_DIR/henryverse'
alias henryverse='cd $CODE_DIR/henryverse'


# PNPM
alias p="pnpm"
alias pd='pnpm dev'
alias pi='pnpm install'
alias px="pnpm exec"

# Bun
alias b="bun"
alias bd='bun dev'
alias bi='bun install'

# NPM
alias ni='npm install'

# Yarn
alias y='yarn'
alias yd='yarn dev'
alias yi='yarn install'
alias ytd='yarn install;yarn dev'


