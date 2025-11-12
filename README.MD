# Henry Black's Dotfiles

Uses stow to manage the dotfiles.

Example:

Running this will create symlinks in your home directory for the files in the `git` directory.

```bash
stow git
```

Prerequisites:

- Need to install stow: `brew install stow`
- Need this dotfiles repo to be in the home directory e.g. `~/dotfiles` as stow assumes 1) that you call stow from this repo and 2) that the dotfiles repo is in the home directory (as it creates the symlinks in the ../ directory).

## Annoyances

- Because I want to use the same settings.json and keybindings.json in both Cursor and Code, I have to have to manually add a symlink in the Cursor settings directory from the Code settings directory (Code is the source of truth). TODO: this seems broken but works on my mac mini.

```bash
ln -sf ~/dotfiles/code/Library/Application\ Support/Code/User/keybindings.json ~/dotfiles/cursor/Library/Application\ Support/Cursor/User/keybindings.json
ln -sf ~/dotfiles/code/Library/Application\ Support/Code/User/settings.json ~/dotfiles/cursor/Library/Application\ Support/Cursor/User/settings.json
```

## Notes

- This repo used to use Chezmoi but didn't like the flow so I moved to stow
- Lots of ideas/commands stolen from https://evanhahn.com/scripts-i-wrote-that-i-use-all-the-time/
