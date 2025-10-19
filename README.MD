# Henry Black's Dotfiles

## Useful commands

- `chezmoi init` - initializes the dotfiles folder in ~/local/share/chezmoi
- `chezmoi add <file path>` - adds a file to the dotfiles folder
- `chezmoi apply` - applies the dotfiles to the home directory
- `chezmoi edit <file path>` - edits a file using your editor of choice
- `chezmoi status` - quick summary of what files would change if you ran chezmoi apply
- `chezmoi diff` - shows the changes that chezmoi apply would make to your home directory
- `chezmoi forget <file path>` - removes a file from the dotfiles folder and stops chezmoi from managing it

## Notes

### Handling VSCode and Cursor settings

I want to use a single shared settings file for VSCode AND Cursor. This conflicts with Chezmoi's default way of handling files (i.e. that the file exists in one location).

To handle this, I did the following:

1. Moved my settings.json and keybindings.json to `<chezmoi dir>/code/`
2. Created the equivilent files that are prefixed with `symlink_` in the chezmoi dir (using the path that correlates with VSCode and Cursor locations)

   - `~/.local/share/chezmoi/private_Library/private_Application Support/private_Code/User/symlink_keybindings.json.tmpl`
   - `~/.local/share/chezmoi/private_Library/private_Application Support/private_Cursor/User/symlink_keybindings.json.tmpl`

3. Added the `code/` dir to `.chezmoiignore` (so Chezmoi doesn't think it is a file that should be synced to home)
4. Ran `chezmoi apply`

This means that Chezmoi creates a symlink in the correct location on the computer. The `code/` directory is the source of truth but because it uses symlinks, any changes that I make via the Cursor/Code UIs will update the source of truth correctly (this last bit is important and is why this technique was needed). This also means that running `chezmoi apply` handles everything and I can still set up my env with a single command.

Note: this directory path is Mac specific so I will need to set up Linux once I have my machine
