# dotfiles

Personal environment setup for Arch Linux.

## Fresh install

```bash
curl -fsSL https://raw.githubusercontent.com/PuemMTH/dotfiles/main/install.sh -o install.sh && bash install.sh
```

## What it installs

- **zsh** + Oh My Zsh (theme: robbyrussell)
- Plugins: zsh-autosuggestions, zsh-syntax-highlighting, sudo, copyfile, jsontools
- **mise** (version manager for node, python, etc.)
- **bun** (JS runtime/package manager)
- Symlinks: `.zshrc`, `.gitconfig`, `.bashrc`, `.tmux.conf`, `.wezterm.lua`, `.vimrc`

## Config highlights

- **tmux** — mouse scroll, 50k scrollback, Catppuccin-inspired status bar
- **WezTerm** — Tokyo Night theme, Cmd+Click to open images (select filename → Cmd+Click for names with spaces)
- **vim** — syntax highlighting for Lua, Python, Go, JSON, Markdown, tmux; 2-space indent

## Secrets

After install, edit `~/.zshrc.local` with your personal API keys and passwords.
This file is **never committed to git**.
