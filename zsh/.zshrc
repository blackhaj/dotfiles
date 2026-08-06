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

detect_homebrew_bin() {
	if [[ -x /opt/homebrew/bin/brew ]]; then
		print -r -- /opt/homebrew/bin/brew
	elif [[ -x /usr/local/bin/brew ]]; then
		print -r -- /usr/local/bin/brew
	elif command_exists brew; then
		command -v brew
	fi
}

pnpm_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
pnpm_completion_file="$pnpm_cache_dir/pnpm-completion.zsh"
gcloud_sdk_root="$HOME/google-cloud-sdk"
gcloud_path_init="$gcloud_sdk_root/path.zsh.inc"
gcloud_completion_init="$gcloud_sdk_root/completion.zsh.inc"

setup_pnpm_completion() {
	mkdir -p "$pnpm_cache_dir"
	# Rebuild when cache is missing or older than the pnpm executable.
	if [[ ! -s "$pnpm_completion_file" || "$pnpm_completion_file" -ot "$(command -v pnpm)" ]]; then
		pnpm completion zsh >"$pnpm_completion_file" 2>/dev/null
	fi
	source "$pnpm_completion_file"
}

setup_pnpm_shell_completion_plugin() {
	local plugin_dir

	plugin_dir="$(antidote path g-plane/pnpm-shell-completion 2>/dev/null)" || return
	if [[ ! -x "$plugin_dir/pnpm-shell-completion" ]]; then
		(
			cd "$plugin_dir" || return
			./zplug.zsh
		)
	fi
}

###############################################################################
# Core shell settings
###############################################################################

export SHELL="$(command -v zsh)"
export HOMEBREW_NO_ENV_HINTS=1

if [[ -z "${HOMEBREW_PREFIX:-}" ]]; then
	homebrew_bin="$(detect_homebrew_bin)"
else
	homebrew_bin=""
fi
if [[ -n "$homebrew_bin" ]]; then
	# Load Homebrew's environment early so brewed tools outrank macOS system binaries.
	eval "$("$homebrew_bin" shellenv)"
fi
unset homebrew_bin

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
# Keep pasted text on normal syntax highlighting instead of standout background.
zle_highlight+=(paste:none)

export PNPM_HOME="$HOME/Library/pnpm"
add_to_path_front "$PNPM_HOME"
add_to_path_front "$HOME/bin"

# Script Kit + tooling bins
add_to_path_front "$HOME/.kenv/bin"
add_to_path_front "$HOME/.kit/bin"
add_to_path_front "$HOME/.lmstudio/bin"

if [[ -r "$gcloud_path_init" ]]; then
	source "$gcloud_path_init"
fi

# Vite+ CLI + shell wrapper.
if [[ -r "$HOME/.vite-plus/env" ]]; then
	source "$HOME/.vite-plus/env"
fi

###############################################################################
# Plugin manager bootstrap (Antidote)
###############################################################################

ANTIDOTE_PATH="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/antidote/share/antidote/antidote.zsh"
source "$ANTIDOTE_PATH"

if interactive_shell; then
	# Completion widgets/tools from plugins (e.g. fzf-tab) depend on zsh/complist.
	zmodload zsh/complist
	# Completion definitions must be added to fpath before compinit scans it.
	antidote load "$HOME/dotfiles/zsh/.zsh_completion_plugins.txt" \
		"${ZDOTDIR:-$HOME}/.zsh_completion_plugins.zsh"
	autoload -Uz compinit
	zcompdump_file="${ZDOTDIR:-$HOME}/.zcompdump"
	if [[ -s "$zcompdump_file" \
		&& "$zcompdump_file" -nt "$HOME/dotfiles/zsh/.zsh_plugins.txt" \
		&& "$zcompdump_file" -nt "$HOME/dotfiles/zsh/.zsh_completion_plugins.txt" ]]; then
		compinit -C -d "$zcompdump_file"
	else
		compinit -d "$zcompdump_file"
	fi
	unset zcompdump_file

	# Completion behavior tweaks for accuracy and readability.
	# Keep completion case-insensitive and colorized,
	# and dim completion headers.
	zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
	zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
	zstyle ':completion:*' completer _complete
	zstyle ':completion:*' format $'\e[2mCompleting %d\e[m'
	# Hide internal dot-prefixed executables (for example ImageMagick shims)
	# from command-name completion.
	zstyle ':completion:*:*:-command-:*:commands' ignored-patterns '.*'

	# Use editor-like word boundaries: only alphanumeric characters form words,
	# so Option-Delete/Ctrl-W stops at path separators and punctuation.
	autoload -Uz select-word-style
	select-word-style bash

	# Fish-style prefix history search: type part of a command, then press
	# Up/Down to cycle through matching history without opening a search UI.
	autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
	zle -N up-line-or-beginning-search
	zle -N down-line-or-beginning-search
	for keymap in emacs viins; do
		[[ -n "${terminfo[kcuu1]}" ]] && bindkey -M "$keymap" "${terminfo[kcuu1]}" up-line-or-beginning-search
		[[ -n "${terminfo[kcud1]}" ]] && bindkey -M "$keymap" "${terminfo[kcud1]}" down-line-or-beginning-search
		bindkey -M "$keymap" '^[[A' up-line-or-beginning-search
		bindkey -M "$keymap" '^[[B' down-line-or-beginning-search
	done

	# Initialize plugins from .zsh_plugins.txt.
	# Prefer history, then fall back to Zsh completion for paths and CLI options.
	ZSH_AUTOSUGGEST_STRATEGY=(history completion)
	antidote load
fi

###############################################################################
# Shared shell configuration
###############################################################################

# Need this before alias/env imports because aliases may reference shared variables.
source "$HOME/dotfiles/shared-shell/vars.sh"
source "$HOME/dotfiles/shared-shell/functions.sh"
source "$HOME/dotfiles/shared-shell/aliases.sh"
source "$HOME/dotfiles/shared-shell/work-aliases.sh"
source "$HOME/dotfiles/shared-shell/env.sh"

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

		# Add workspace packages, dependencies, and package.json scripts. Load
		# after pnpm's native completion because this plugin registers _pnpm.
		pnpm_completion_plugin_dir="$(antidote path g-plane/pnpm-shell-completion 2>/dev/null)"
		if [[ -x "$pnpm_completion_plugin_dir/pnpm-shell-completion" ]]; then
			source "$pnpm_completion_plugin_dir/pnpm-shell-completion.plugin.zsh"
		fi
		unset pnpm_completion_plugin_dir
	fi

	if [[ -r "$gcloud_completion_init" ]]; then
		source "$gcloud_completion_init"
	fi

	command_exists mise && eval "$(mise activate zsh)"

	# Atuin records contextual history and owns Ctrl+R. Native Zsh widgets keep
	# Up/Down as quiet Fish-style prefix history cycling.
	if [[ -r "$HOME/.atuin/bin/env" ]]; then
		source "$HOME/.atuin/bin/env"
	fi
	if command_exists atuin; then
		eval "$(atuin init zsh --disable-up-arrow)"
	fi
fi

# pnpm
export PNPM_HOME="/Users/henryblack/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
export PATH="$HOME/.local/bin:$PATH"
