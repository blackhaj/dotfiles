# Fish completion for w command
# Save this as ~/.config/fish/completions/w.fish

# Complete project names for the first argument
complete -c w -f -n __fish_is_first_token -a '(for dir in ~/maze/*/; test -d "$dir/.git" && basename "$dir"; end)'

# Complete special flags
complete -c w -f -l list -d 'List all worktrees'
complete -c w -f -l rm -d 'Remove a worktree'

# Complete worktree names for the second argument (when not using special flags)
complete -c w -f -n '__fish_is_nth_token 2; and not __fish_seen_subcommand_from --list --rm' -a '(__w_complete_worktrees)'

# Complete project names for --rm flag (3rd position)
complete -c w -f -n '__fish_seen_subcommand_from --rm; and __fish_is_nth_token 2' -a '(for dir in ~/maze/*/; test -d "$dir/.git" && basename "$dir"; end)'

# Complete worktree names for --rm flag (4th position)
complete -c w -f -n '__fish_seen_subcommand_from --rm; and __fish_is_nth_token 3' -a '(__w_complete_worktrees_for_rm)'

# Helper function to check if we're at the nth token
function __fish_is_nth_token -a n
    test (count (commandline -opc)) -eq $n
end

function __fish_is_first_token
    __fish_is_nth_token 1
end

# Function to complete worktree names based on the project
function __w_complete_worktrees
    set -l projects_dir "$HOME/maze"
    set -l worktrees_dir "$HOME/maze/worktrees"

    # Get the project from the command line
    set -l tokens (commandline -opc)
    if test (count $tokens) -ge 2
        set -l project $tokens[2]

        # For core project, check both old and new locations
        if test "$project" = core
            # Check old location
            if test -d "$projects_dir/core-wts"
                for wt in $projects_dir/core-wts/*/
                    if test -d "$wt"
                        basename "$wt"
                    end
                end
            end
            # Check new location
            if test -d "$worktrees_dir/core"
                for wt in $worktrees_dir/core/*/
                    if test -d "$wt"
                        basename "$wt"
                    end
                end
            end
        else
            # For other projects, check new location only
            if test -d "$worktrees_dir/$project"
                for wt in $worktrees_dir/$project/*/
                    if test -d "$wt"
                        basename "$wt"
                    end
                end
            end
        end
    end
end

# Function to complete worktree names for --rm command
function __w_complete_worktrees_for_rm
    set -l projects_dir "$HOME/maze"
    set -l worktrees_dir "$HOME/maze/worktrees"

    # Get the project from the command line (3rd token after w --rm)
    set -l tokens (commandline -opc)
    if test (count $tokens) -ge 3
        set -l project $tokens[3]

        # For core project, check both old and new locations
        if test "$project" = core
            # Check old location
            if test -d "$projects_dir/core-wts"
                for wt in $projects_dir/core-wts/*/
                    if test -d "$wt"
                        basename "$wt"
                    end
                end
            end
            # Check new location
            if test -d "$worktrees_dir/core"
                for wt in $worktrees_dir/core/*/
                    if test -d "$wt"
                        basename "$wt"
                    end
                end
            end
        else
            # For other projects, check new location only
            if test -d "$worktrees_dir/$project"
                for wt in $worktrees_dir/$project/*/
                    if test -d "$wt"
                        basename "$wt"
                    end
                end
            end
        end
    end
end
