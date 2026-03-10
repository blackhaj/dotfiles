# Shell wrapper for the `wt` worktree script.
# Required because scripts can't change the parent shell's directory.
# This evals the `cd` command output by the wt binary and tracks
# previous worktree location for the toggle feature (wt -).
function wt
    set -l worktree_root (if set -q WORKTREE_ROOT; echo $WORKTREE_ROOT; else; echo $HOME/worktrees; end)

    # Save current location before navigating (enables wt - toggle)
    if string match -rq "^$worktree_root/" $PWD
        mkdir -p $worktree_root
        echo $PWD >$worktree_root/.workout_prev
    end

    set -l result (command wt $argv)
    set -l exit_code $status

    if test $exit_code -eq 0
        eval $result
    end

    return $exit_code
end
