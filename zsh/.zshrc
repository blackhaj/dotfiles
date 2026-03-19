export SHELL="$(command -v zsh)"

# source antidote
if [[ -r "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh" ]]; then
	source "/opt/homebrew/opt/antidote/share/antidote/antidote.zsh"
fi

if [[ -o interactive ]]; then
	# completion system required by completion widgets like fzf-tab
	zmodload zsh/complist
	autoload -Uz compinit
	compinit

	# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
	antidote load
fi

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

if [[ -o interactive ]]; then
	# Init starship prompt
	export STARSHIP_CONFIG="$HOME/.config/starship.toml"
	command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"

	# Init zoxide
	command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

	# Ctrl+R fuzzy history search (fzf)
	if command -v fzf >/dev/null 2>&1; then
		source <(fzf --zsh)
	fi

	# bun completions
	if command -v bun >/dev/null 2>&1 && [ -s "/Users/henryblack/.bun/_bun" ]; then
		source "/Users/henryblack/.bun/_bun"
	fi

	# pnpm completion (zsh)
	if command -v pnpm >/dev/null 2>&1; then
		pnpm_completion_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/pnpm-completion.zsh"
		mkdir -p "${pnpm_completion_cache%/*}"
		if [[ ! -s "$pnpm_completion_cache" || "$pnpm_completion_cache" -ot "$(command -v pnpm)" ]]; then
			pnpm completion zsh >"$pnpm_completion_cache" 2>/dev/null
		fi
		source "$pnpm_completion_cache"
	fi

	command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"
fi

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

# pnpm
export PNPM_HOME="/Users/henryblack/Library/pnpm"
if command -v pnpm >/dev/null 2>&1; then
	case ":$PATH:" in
		*":$PNPM_HOME:") ;;
		*) export PATH="$PNPM_HOME:$PATH" ;;
	esac
fi
# pnpm end
