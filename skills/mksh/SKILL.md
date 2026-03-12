---
name: mksh
description: Add a new shell script to the dotfiles bin. Use when the user wants to create a new script, add a command to ~/dotfiles/bin/bin/, or copy a script from an external source into the dotfiles repo.
---

# Add a New Shell Script to Dotfiles

Scripts live in `~/dotfiles/bin/bin/` and are committed to the dotfiles repo.

## Workflow

Make a todo list and work through these steps.

### 1. Scaffold the Script

Run `mksh <scriptname>` to create a properly scaffolded file:

```bash
mksh <scriptname>
```

This creates `~/dotfiles/bin/bin/<scriptname>` with:

```bash
#!/usr/bin/env bash
# Description: <ADD>


set -e # Exit on error
set -u # Exit on undefined variable
set -o pipefail # Exit on pipe error
```

And makes it executable.

### 2. Write the Header

Fill in the `# Description:` line. If the script is copied from an external source, add a `# Source:` line immediately after:

```bash
#!/usr/bin/env bash
# Description: One-line description of what the script does
# Source: https://github.com/example/repo/blob/main/path/to/script.sh

set -e # Exit on error
set -u # Exit on undefined variable
set -o pipefail # Exit on pipe error
```

If the script is original (not copied), omit the `# Source:` line.

### 3. Write the Script Body

Implement the script logic after the header. Keep the `set -e/u/pipefail` lines — they enforce strict error handling.

### 4. Commit and Push

```bash
git add bin/bin/<scriptname>
git commit -m "add <scriptname> script"
git push -u origin <branch>
```

## Example: Adding a Copied Script

This is how `wt` and `wt-delete` were added from @karlhepler's nixpkgs:

```bash
# Scaffold
mksh wt

# Then edit the file to have:
#!/usr/bin/env bash
# Description: Create and navigate to git worktrees in ~/worktrees/ (or $WORKTREE_ROOT)
# Source: https://github.com/karlhepler/nixpkgs/blob/main/modules/git/workout.bash

set -e # Exit on error
set -u # Exit on undefined variable
set -o pipefail # Exit on pipe error

# ... script body from source ...
```

## Notes

- `mksh` opens the new file in `$EDITOR` after creation
- The script is automatically `chmod u+x`
- All scripts in `bin/bin/` are on `$PATH` when dotfiles is set up
