#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"
DOTFILES_REPO="https://github.com/PuemMTH/dotfiles"

echo "==> Dotfiles installer"
echo ""

# --- Install packages (Arch Linux) ---
if command -v pacman &>/dev/null; then
  echo "==> Installing packages (requires sudo)..."
  sudo pacman -Sy --needed --noconfirm \
    zsh git github-cli curl wget vim base-devel \
    unzip openconnect
fi

# --- Clone repo if not already present ---
if [ ! -d "$DOTFILES" ]; then
  echo "==> Cloning dotfiles..."
  git clone "$DOTFILES_REPO" "$DOTFILES"
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

echo "==> Activating mise..."
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"

echo "==> Installing tools via mise..."
mise use -g rust node npm pnpm bun python uv

# --- bun ---
if ! command -v bun &>/dev/null; then
  echo "==> Installing bun..."
  curl -fsSL https://bun.sh/install | bash
fi

# --- opencode ---
if ! command -v opencode &>/dev/null; then
  echo "==> Installing opencode..."
  npm install -g opencode-ai
fi

# --- Claude Code ---
if ! command -v claude &>/dev/null; then
  echo "==> Installing Claude Code..."
  npm install -g @anthropic-ai/claude-code
fi

# --- Gemini CLI ---
if ! command -v gemini &>/dev/null; then
  echo "==> Installing Gemini CLI..."
  npm install -g @google/gemini-cli
fi

# --- yay (AUR helper) ---
if ! command -v yay &>/dev/null; then
  echo "==> Installing yay..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && makepkg -si --noconfirm)
  rm -rf /tmp/yay
fi

# --- Microsoft Edge ---
if ! command -v microsoft-edge-stable &>/dev/null; then
  echo "==> Installing Microsoft Edge..."
  yay -S --noconfirm microsoft-edge-stable-bin
fi

# --- Bluetooth ---
echo "==> Enabling Bluetooth..."
sudo systemctl enable --now bluetooth

# --- Docker ---
if ! command -v docker &>/dev/null; then
  echo "==> Installing Docker..."
  sudo pacman -Sy --needed --noconfirm docker docker-compose
  sudo systemctl enable --now docker
  sudo usermod -aG docker "$USER"
  echo "    Docker installed. Log out and back in for group membership to take effect."
fi

# --- Zed editor ---
if ! command -v zed &>/dev/null; then
  echo "==> Installing Zed editor..."
  curl -fsSL https://zed.dev/install.sh | sh
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

symlink "$DOTFILES/zsh/.zshrc"           "$HOME/.zshrc"
symlink "$DOTFILES/git/.gitconfig"       "$HOME/.gitconfig"
symlink "$DOTFILES/bash/.bashrc"         "$HOME/.bashrc"
symlink "$DOTFILES/tmux/.tmux.conf"      "$HOME/.tmux.conf"
symlink "$DOTFILES/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"
symlink "$DOTFILES/vim/.vimrc"           "$HOME/.vimrc"

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
