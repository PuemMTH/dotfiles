# dotfiles

Personal environment setup for Arch Linux.

## Fresh install

```bash
curl -fsSL https://raw.githubusercontent.com/PuemMTH/dotfiles/main/install.sh | bash
```

## What it installs

- **zsh** + Oh My Zsh (theme: robbyrussell)
- Plugins: zsh-autosuggestions, zsh-syntax-highlighting, sudo, copyfile, jsontools
- **mise** (version manager for node, python, etc.)
- **bun** (JS runtime/package manager)
- Symlinks: `.zshrc`, `.gitconfig`, `.bashrc`

## Secrets

After install, edit `~/.zshrc.local` with your personal API keys and passwords.
This file is **never committed to git**.
