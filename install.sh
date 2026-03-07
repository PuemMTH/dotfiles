#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"
DOTFILES_REPO="https://github.com/PuemMTH/dotfiles"

echo "==> Dotfiles installer"
echo ""

# --- Clone repo if not already present ---
if [ ! -d "$DOTFILES" ]; then
  echo "==> Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES"
fi

# --- Install packages (Arch Linux) ---
if command -v pacman &>/dev/null; then
  echo "==> Installing packages..."
  sudo pacman -Sy --needed --noconfirm \
    zsh git curl wget vim base-devel \
    unzip openconnect
fi

# --- Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "==> Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# --- zsh plugins ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "==> Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "==> Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# --- mise ---
if ! command -v mise &>/dev/null; then
  echo "==> Installing mise..."
  curl https://mise.run | sh
fi

# --- bun ---
if ! command -v bun &>/dev/null; then
  echo "==> Installing bun..."
  curl -fsSL https://bun.sh/install | bash
fi

# --- Symlink dotfiles ---
echo "==> Symlinking dotfiles..."

symlink() {
  local src="$1"
  local dst="$2"
  if [ -f "$dst" ] && [ ! -L "$dst" ]; then
    echo "    Backing up $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  echo "    $dst -> $src"
}

symlink "$DOTFILES/zsh/.zshrc"      "$HOME/.zshrc"
symlink "$DOTFILES/git/.gitconfig"  "$HOME/.gitconfig"
symlink "$DOTFILES/bash/.bashrc"    "$HOME/.bashrc"

# --- Local secrets template ---
if [ ! -f "$HOME/.zshrc.local" ]; then
  echo "==> Creating ~/.zshrc.local template (add your secrets here)..."
  cat > "$HOME/.zshrc.local" <<'EOF'
# Local secrets — NOT tracked by git

# VPN
export VPN_USER="807361"
export VPN_PASSWORD="your_vpn_password_here"

# APIs
export BASE_URL="https://home.puem.me"
export CHANNEL_ACCESS_TOKEN=""
export CHANNEL_SECRET=""
export MINIMAX_API_KEY=""
EOF
  echo "    Edit ~/.zshrc.local and fill in your secrets."
fi

# --- Set zsh as default shell ---
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "==> Setting zsh as default shell..."
  chsh -s "$(which zsh)"
fi

echo ""
echo "==> Done! Open a new terminal or run: exec zsh"
echo "==> Don't forget to fill in ~/.zshrc.local with your secrets."
