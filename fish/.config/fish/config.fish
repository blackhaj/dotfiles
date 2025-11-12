source "$HOME/dotfiles/shared-shell/aliases.sh"
source "$HOME/dotfiles/shared-shell/vars.sh"
source "$HOME/dotfiles/shared-shell/work-aliases.sh"
source "$HOME/dotfiles/shared-shell/env.sh"
# Add my bin scripts to the PATH
set PATH $PATH $HOME/bin/

set -x PATH /usr/local/bin /opt/homebrew/bin $PATH

# Test

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# FISH RELATED
# Stops the fish greeting
set -U fish_greeting
set -U fish_color_command 5281EB
set -U fish_color_quote ce9178

# Copied orbstack over from zsh
source ~/.orbstack/shell/init.fish 2>/dev/null || :

# Init starship prompt
export STARSHIP_CONFIG="$HOME/.config/starship.toml"
starship init fish | source

# Script Kit
export PATH="$PATH:/Users/henryblack/.kenv/bin"
export PATH="$PATH:/Users/henryblack/.kit/bin"

# Homebrew
set -gx PATH /opt/homebrew/bin $PATH
export HOMEBREW_NO_ENV_HINTS=1

export EDITOR="cursor --wait"

# Brew completions
if test -d (brew --prefix)"/share/fish/completions"
    set -p fish_complete_path (brew --prefix)/share/fish/completions
end

if test -d (brew --prefix)"/share/fish/vendor_completions.d"
    set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
end

# Postgres tools like pg_dump
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

export PATH="$PATH:/Users/henryblack/.local/bin"

# Disable ERD in monorepo
export DISABLE_ERD=true

# Init zoxide
zoxide init fish | source

# Set up Mise
/opt/homebrew/bin/mise activate fish | source

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

mise activate fish --shims | source

# pnpm
set -gx PNPM_HOME /Users/henryblack/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# opencode
fish_add_path /Users/henryblack/.opencode/bin

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/henryblack/.lmstudio/bin
# End of LM Studio CLI section
