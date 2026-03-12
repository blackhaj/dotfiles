# Commands
alias ls='eza --group-directories-first --icons -a -x --hyperlink'
alias tree='eza --group-directories-first --icons -x --hyperlink -I node_modules -T'
alias cat='bat'
alias nid="bunx nanoid --alphabet 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwx
yz0123456789' --size"
# Ignore .DS_Store files when using stow
alias stow='stow --ignore=\\.DS_Store\$'
alias cc="IS_SANDBOX=1 claude --dangerously-skip-permissions"

# Git
alias gco='git checkout'
alias gcob='gco -b'
alias gb='git branch'
alias gpf="git push --force-with-lease"
alias grc='git rebase --continue'
alias grm='git rebase main'
alias gs='git status'
alias gstr="git stash -u && git rebase main && git stash pop"
alias prm='$DOTFILES_DIR/scripts/pr-post/pr-post.sh'

#Navigation
alias cod='cd $CODE_DIR'
alias proj='cd $PROJECTS_DIR'
alias dots='code $DOTFILES_DIR'
alias yard='cd $PROJECTS_DIR/yard'
alias yardo='cursor $PROJECTS_DIR/yard'

# PNPM
alias p="pnpm"
alias pd='pnpm dev'
# alias pi='pnpm install'
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

# try — fuzzy project directory navigator
# Wraps the bun script so that `cd` works in the current shell session
try() {
  local dir
  dir=$(command try "$@") && cd "$dir"
}

# Other
