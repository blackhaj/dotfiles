# .zshrc
#
# Purpose:
#   Central shell bootstrap for:
#   - shared aliases/environment
#   - plugin tooling
#   - shell completions and interactive UX
#
# Notes:
#   Keep this file intentionally lean; source long command-specific logic from
#   $HOME/dotfiles/shared-shell/*.

###############################################################################
# Helpers
###############################################################################

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

interactive_shell() {
	[[ -o interactive ]]
}

add_to_path_front() {
	local directory=$1

	[[ -d "$directory" ]] || return
	case ":$PATH:" in
		*":$directory:") ;;
		*) export PATH="$directory:$PATH" ;;
	esac
}

safe_eval_init() {
	local init_cmd=$1
	command_exists "$init_cmd" && eval "$($2)"
}

pnpm_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
pnpm_completion_file="$pnpm_cache_dir/pnpm-completion.zsh"

setup_pnpm_completion() {
	mkdir -p "$pnpm_cache_dir"
	# Rebuild when cache is missing or older than the pnpm executable.
	if [[ ! -s "$pnpm_completion_file" || "$pnpm_completion_file" -ot "$(command -v pnpm)" ]]; then
		pnpm completion zsh >"$pnpm_completion_file" 2>/dev/null
	fi
	source "$pnpm_completion_file"
}

###############################################################################
# Core shell settings
###############################################################################

export SHELL="$(command -v zsh)"
export HOMEBREW_NO_ENV_HINTS=1

export SAVEHIST=100000
export HISTSIZE=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
# Allow comments in interactive command lines.
setopt INTERACTIVE_COMMENTS
# Complete inside words, and place completion text at word end.
setopt COMPLETE_IN_WORD
setopt ALWAYS_TO_END
HIST_STAMPS="dd.mm.yyyy"

export PNPM_HOME="$HOME/Library/pnpm"
add_to_path_front "$PNPM_HOME"
add_to_path_front "$HOME/bin"

# Script Kit + tooling bins
add_to_path_front "$HOME/.kenv/bin"
add_to_path_front "$HOME/.kit/bin"
add_to_path_front "$HOME/.lmstudio/bin"

# Vite+ CLI + shell wrapper.
. "$HOME/.vite-plus/env"

###############################################################################
# Plugin manager bootstrap (Antidote)
###############################################################################

ANTIDOTE_PATH="/opt/homebrew/opt/antidote/share/antidote/antidote.zsh"
if [[ -r "$ANTIDOTE_PATH" ]]; then
	source "$ANTIDOTE_PATH"
fi

if interactive_shell; then
	# Completion widgets/tools from plugins (e.g. fzf-tab) depend on zsh/complist.
	zmodload zsh/complist
	autoload -Uz compinit
	compinit

	# Completion behavior tweaks for accuracy and readability.
	# Keep completion case-insensitive and colorized,
	# allow approximate matches, and dim completion headers.
	zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
	zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
	zstyle ':completion:*' completer _complete _approximate
	zstyle ':completion:*' format $'\e[2mCompleting %d\e[m'

	# Initialize plugins from .zsh_plugins.txt.
	antidote load
fi

###############################################################################
# Shared shell configuration
###############################################################################

# Need this before alias/env imports because aliases may reference shared variables.
source "$HOME/dotfiles/shared-shell/vars.sh"
source "$HOME/dotfiles/shared-shell/aliases.sh"
source "$HOME/dotfiles/shared-shell/work-aliases.sh"
source "$HOME/dotfiles/shared-shell/env.sh"

# zsh wrapper for `wt` so directory changes happen in the parent shell.
# The `wt` binary prints `cd ...` commands, which can only take effect
# when executed by a shell function (not when running as a plain external command).
wt() {
	local worktree_root="${WORKTREE_ROOT:-$HOME/worktrees}"
	local wt_binary="${WT_BACKEND:-${HOME}/bin/wt}"
	local wt_output wt_exit_code

	if [[ ! -x "$wt_binary" ]]; then
		print -u2 -- "wt: backend binary not found or not executable"
		return 127
	fi

	if [[ "$PWD" == "$worktree_root"/* ]]; then
		mkdir -p "$worktree_root"
		echo "$PWD" >"$worktree_root/.workout_prev"
	fi

	wt_output="$("$wt_binary" "$@")"
	wt_exit_code=$?
	if (( wt_exit_code == 0 )); then
		if [[ "$wt_output" == cd\ * ]]; then
			eval -- "$wt_output"
		else
		print -r -- "$wt_output"
		fi
	fi
	return "$wt_exit_code"
}

# try — fuzzy project directory navigator.
# Wraps the bun `try` script so `cd` happens in the current shell.
try() {
	local dir
	dir=$(command try "$@") && cd "$dir"
}

###############################################################################
# Interactive-only tooling
###############################################################################

if interactive_shell; then
	export STARSHIP_CONFIG="$HOME/.config/starship.toml"

	command_exists starship && eval "$(starship init zsh)"
	command_exists zoxide && eval "$(zoxide init zsh)"

	# Ctrl+R fuzzy history search (fzf).
	command_exists fzf && source <(fzf --zsh)

	# bun completions.
	if command_exists bun && [[ -s "$HOME/.bun/_bun" ]]; then
		source "$HOME/.bun/_bun"
	fi

	# pnpm completions, cached for startup speed.
	if command_exists pnpm; then
		setup_pnpm_completion
	fi

	command_exists mise && eval "$(mise activate zsh)"
fi
