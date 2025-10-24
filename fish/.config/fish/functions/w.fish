#!/usr/bin/env fish
# Take from - https://gist.github.com/rorydbain/e20e6ab0c7cc027fc1599bd2e430117d
# Found in - https://incident.io/blog/shipping-faster-with-claude-code-and-git-worktrees

# Multi-project worktree manager with Claude support
# 
# ASSUMPTIONS & SETUP:
# - Your git projects live in: ~/projects/
# - Worktrees will be created in: ~/projects/worktrees/<project>/<branch>
# - New branches will be named: <your-username>/<feature-name>
#
# DIRECTORY STRUCTURE EXAMPLE:
# ~/projects/
# ├── my-app/              (main git repo)
# ├── another-project/     (main git repo)
# └── worktrees/
#     ├── my-app/
#     │   ├── feature-x/   (worktree)
#     │   └── bugfix-y/    (worktree)
#     └── another-project/
#         └── new-feature/ (worktree)
#
# CUSTOMIZATION:
# To use different directories, modify these lines in the w() function:
#   set projects_dir "$HOME/projects"
#   set worktrees_dir "$HOME/projects/worktrees"
#
# INSTALLATION:
# 1. Save this script as ~/.config/fish/functions/w.fish
#
# 2. Create completion file at ~/.config/fish/completions/w.fish (see bottom of this file)
#
# 3. Restart your fish shell or run: source ~/.config/fish/functions/w.fish
#
# 4. Test it works: w <TAB> should show your projects
#
# USAGE:
#   w <project> <worktree>              # cd to worktree (creates if needed)
#   w <project> <worktree> <command>    # run command in worktree
#   w --list                            # list all worktrees
#   w --rm <project> <worktree>         # remove worktree
#
# EXAMPLES:
#   w myapp feature-x                   # cd to feature-x worktree
#   w myapp feature-x claude            # run claude in worktree
#   w myapp feature-x gst               # git status in worktree
#   w myapp feature-x gcmsg "fix: bug"  # git commit in worktree

# Multi-project worktree manager
function w
    set -l projects_dir "$HOME/maze"
    set -l worktrees_dir "$HOME/maze/worktrees"

    # Handle special flags
    if test "$argv[1]" = --list
        echo "=== All Worktrees ==="
        # Check new location
        if test -d "$worktrees_dir"
            for project in $worktrees_dir/*/
                if test -d "$project"
                    set project_name (basename "$project")
                    echo ""
                    echo "[$project_name]"
                    for wt in $project/*/
                        if test -d "$wt"
                            echo "  • "(basename "$wt")
                        end
                    end
                end
            end
        end
        # Also check old core-wts location
        if test -d "$projects_dir/core-wts"
            echo ""
            echo "[core] (legacy location)"
            for wt in $projects_dir/core-wts/*/
                if test -d "$wt"
                    echo "  • "(basename "$wt")
                end
            end
        end
        return 0
    else if test "$argv[1]" = --rm
        set -l project "$argv[2]"
        set -l worktree "$argv[3]"
        if test -z "$project" -o -z "$worktree"
            echo "Usage: w --rm <project> <worktree>"
            return 1
        end
        # Check both locations for core
        if test "$project" = core -a -d "$projects_dir/core-wts/$worktree"
            cd "$projects_dir/$project" && git worktree remove "$projects_dir/core-wts/$worktree"
        else
            set -l wt_path "$worktrees_dir/$project/$worktree"
            if not test -d "$wt_path"
                echo "Worktree not found: $wt_path"
                return 1
            end
            cd "$projects_dir/$project" && git worktree remove "$wt_path"
        end
        return $status
    end

    # Normal usage: w <project> <worktree> [command...]
    set -l project "$argv[1]"
    set -l worktree "$argv[2]"
    set -l command $argv[3..-1]

    if test -z "$project" -o -z "$worktree"
        echo "Usage: w <project> <worktree> [command...]"
        echo "       w --list"
        echo "       w --rm <project> <worktree>"
        return 1
    end

    # Check if project exists
    if not test -d "$projects_dir/$project"
        echo "Project not found: $projects_dir/$project"
        return 1
    end

    # Determine worktree path - check multiple locations
    set -l wt_path ""
    if test "$project" = core
        # For core, check old location first
        if test -d "$projects_dir/core-wts/$worktree"
            set wt_path "$projects_dir/core-wts/$worktree"
        else if test -d "$worktrees_dir/$project/$worktree"
            set wt_path "$worktrees_dir/$project/$worktree"
        end
    else
        # For other projects, check new location
        if test -d "$worktrees_dir/$project/$worktree"
            set wt_path "$worktrees_dir/$project/$worktree"
        end
    end

    # If worktree doesn't exist, create it
    if test -z "$wt_path" -o ! -d "$wt_path"
        echo "Creating new worktree: $worktree"

        # Ensure worktrees directory exists
        mkdir -p "$worktrees_dir/$project"

        # Determine branch name (use current username prefix)
        set -l branch_name "$USER/$worktree"

        # Create the worktree in new location
        set wt_path "$worktrees_dir/$project/$worktree"
        cd "$projects_dir/$project" && git worktree add "$wt_path" -b "$branch_name"
        if test $status -ne 0
            echo "Failed to create worktree"
            return 1
        end
    end

    # Execute based on number of arguments
    if test (count $command) -eq 0
        # No command specified - just cd to the worktree
        cd "$wt_path"
    else
        # Command specified - run it in the worktree without cd'ing
        set -l old_pwd (pwd)
        cd "$wt_path"
        eval $command
        set -l exit_code $status
        cd "$old_pwd"
        return $exit_code
    end
end
