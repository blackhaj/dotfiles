# ----------------------------------------------------------------------------
# 1. SHELL SCRIPT IMPORTS (need to be before other imports)
# ----------------------------------------------------------------------------
source "$HOME/dotfiles/shared-shell/vars.sh" # need to be before other imports as e.g. aliases uses the vars
source "$HOME/dotfiles/shared-shell/aliases.sh"
source "$HOME/dotfiles/shared-shell/work-aliases.sh"
source "$HOME/dotfiles/shared-shell/env.sh"

# ----------------------------------------------------------------------------
# 2. ENVIRONMENT VARIABLES
# ----------------------------------------------------------------------------
set -gx STARSHIP_CONFIG "$HOME/.config/starship.toml"
set -gx HOMEBREW_NO_ENV_HINTS 1
set -gx EDITOR "cursor --wait"
set -gx DISABLE_ERD true # Disable ERD in monorepo
set -gx PNPM_HOME /Users/henryblack/Library/pnpm

# Cache brew prefix to avoid multiple expensive calls
set -q HOMEBREW_PREFIX; or set -gx HOMEBREW_PREFIX /opt/homebrew

# ----------------------------------------------------------------------------
# 3. PATH MODIFICATIONS (using fish_add_path for idempotency)
# ----------------------------------------------------------------------------
# System and Homebrew paths
fish_add_path /usr/local/bin
fish_add_path $HOMEBREW_PREFIX/bin

# User bins
fish_add_path $HOME/bin

# Script Kit
fish_add_path /Users/henryblack/.kenv/bin
fish_add_path /Users/henryblack/.kit/bin

# Postgres tools like pg_dump
fish_add_path $HOMEBREW_PREFIX/opt/libpq/bin

# Local bin
fish_add_path /Users/henryblack/.local/bin

# pnpm
if not string match -q -- $PNPM_HOME $PATH
    fish_add_path $PNPM_HOME
end

# opencode
fish_add_path /Users/henryblack/.opencode/bin

# LM Studio CLI
fish_add_path /Users/henryblack/.lmstudio/bin

# ----------------------------------------------------------------------------
# 4. TOOL INITIALIZATIONS (Non-interactive)
# ----------------------------------------------------------------------------
# OrbStack
source ~/.orbstack/shell/init.fish 2>/dev/null || :

# Mise - OPTIMIZED: Only run once with combined flags
if command -q mise
    $HOMEBREW_PREFIX/bin/mise activate fish --shims | source
end

# ----------------------------------------------------------------------------
# 5. INTERACTIVE-ONLY SETTINGS
# ----------------------------------------------------------------------------
if status is-interactive
    # Fish appearance
    set -g fish_greeting

    # Theme colors (migrated from fish 4.3 universal vars)
    set -g fish_color_autosuggestion brblack
    set -g fish_color_cancel -r
    set -g fish_color_command 5281EB
    set -g fish_color_comment red
    set -g fish_color_cwd green
    set -g fish_color_cwd_root red
    set -g fish_color_end green
    set -g fish_color_error brred
    set -g fish_color_escape brcyan
    set -g fish_color_history_current --bold
    set -g fish_color_host normal
    set -g fish_color_host_remote yellow
    set -g fish_color_normal normal
    set -g fish_color_operator brcyan
    set -g fish_color_param cyan
    set -g fish_color_quote ce9178
    set -g fish_color_redirection cyan --bold
    set -g fish_color_search_match white --background=brblack
    set -g fish_color_selection white --bold --background=brblack
    set -g fish_color_status red
    set -g fish_color_user brgreen
    set -g fish_color_valid_path --underline
    set -g fish_pager_color_completion normal
    set -g fish_pager_color_description yellow -i
    set -g fish_pager_color_prefix normal --bold --underline
    set -g fish_pager_color_progress brwhite --background=cyan
    set -g fish_pager_color_selected_background -r

    # Starship prompt - OPTIMIZED: Use cached init if available
    if command -q starship
        # Cache starship init to avoid regenerating each time
        set -l starship_cache "$HOME/.cache/fish/starship_init.fish"
        if not test -f $starship_cache; or test (command -s starship) -nt $starship_cache
            mkdir -p (dirname $starship_cache)
            starship init fish --print-full-init >$starship_cache
        end
        source $starship_cache
    end

    # Zoxide (directory jumper)
    command -q zoxide; and zoxide init fish | source
end

# ----------------------------------------------------------------------------
# 6. COMPLETIONS
# ----------------------------------------------------------------------------
# Brew completions - OPTIMIZED: Use cached HOMEBREW_PREFIX, avoid repeated calls
if test -d $HOMEBREW_PREFIX
    for dir in $HOMEBREW_PREFIX/share/fish/completions $HOMEBREW_PREFIX/share/fish/vendor_completions.d
        test -d $dir; and set -p fish_complete_path $dir
    end
end

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
