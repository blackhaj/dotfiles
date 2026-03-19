export SHELL="$(command -v zsh)"

# source antidote
source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh

# completion system required by completion widgets like fzf-tab
zmodload zsh/complist
autoload -Uz compinit
compinit

# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load

source "$HOME/dotfiles/shared-shell/vars.sh" # need to be before other imports as e.g. aliases uses the vars
source "$HOME/dotfiles/shared-shell/aliases.sh"
source "$HOME/dotfiles/shared-shell/work-aliases.sh"
source "$HOME/dotfiles/shared-shell/env.sh"

# try — fuzzy project directory navigator
# Wraps the bun script so that cd works in the current shell session
try() {
	local dir
	dir=$(command try "$@") && cd "$dir"
}

# Init starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
eval "$(starship init zsh)"

# Init zoxide
eval "$(zoxide init zsh)"

# bun completions
[ -s "/Users/henryblack/.bun/_bun" ] && source "/Users/henryblack/.bun/_bun"

# brew
export HOMEBREW_NO_ENV_HINTS=1

# Script Kit
export PATH="$PATH:/Users/henryblack/.kenv/bin"
export PATH="$PATH:/Users/henryblack/.kit/bin"

export SAVEHIST=100000
export HISTSIZE=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
HIST_STAMPS="dd.mm.yyyy"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/henryblack/.lmstudio/bin"
# End of LM Studio CLI section

eval "$(mise activate zsh)"

# pnpm
export PNPM_HOME="/Users/henryblack/Library/pnpm"
case ":$PATH:" in
	*":$PNPM_HOME:"*) ;;
	*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
