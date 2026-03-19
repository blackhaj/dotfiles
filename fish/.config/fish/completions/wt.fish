# Fish completions for wt (worktree manager)

# Disable file completions
complete -c wt -f

# Special args
complete -c wt -n '__fish_is_first_token' -a '.' -d 'Create worktree for current branch'
complete -c wt -n '__fish_is_first_token' -a '-' -d 'Toggle to previous worktree'
complete -c wt -n '__fish_is_first_token' -a '/' -d 'Open interactive fzf browser'
complete -c wt -n '__fish_is_first_token' -a 'clean' -d 'Delete worktrees with merged branches'
complete -c wt -n '__fish_is_first_token' -a '--help' -d 'Show help'
complete -c wt -n '__fish_is_first_token' -a '-h' -d 'Show help'

# clean subcommand
complete -c wt -n '__fish_seen_subcommand_from clean' -a '--expunge' -d 'Delete ALL worktrees (dangerous!)'

# Branch name completions from local git branches
complete -c wt -n '__fish_is_first_token' -a '(git branch --format "%(refname:short)" 2>/dev/null)' -d 'Local branch'
