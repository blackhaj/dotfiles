
# Added by OrbStack: command-line tools and integration
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

if command -v brew >/dev/null 2>&1; then
  eval "$(brew shellenv zsh)"
fi
