# Notes on my scripts

- Node has a styleText util now that is like Chalk but less colors and built in.
  - API: https://nodejs.org/api/util.html#utilstyletextformat-text-options
  - Colors/modifiers: https://nodejs.org/api/util.html#modifiers
- Terminal kit is a UI library for the terminal - https://github.com/cronvel/terminal-kit/

Tobi's ANSII Styling:

```rb
module UI
  TOKEN_MAP = {
    '{text}' => "\e[39m",
    '{dim_text}' => "\e[90m",
    '{h1}' => "\e[1;33m",
    '{h2}' => "\e[1;36m",
    '{highlight}' => "\e[1;33m",
    '{reset}' => "\e[0m\e[39m\e[49m", '{reset_bg}' => "\e[49m", '{reset_fg}' => "\e[39m",
    '{clear_screen}' => "\e[2J", '{clear_line}' => "\e[2K", '{home}' => "\e[H", '{clear_below}' => "\e[0J",
    '{hide_cursor}' => "\e[?25l", '{show_cursor}' => "\e[?25h",
    '{start_selected}' => "\e[1m", '{end_selected}' => "\e[0m", '{bold}' => "\e[1m"
  }.freeze
```
