# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting sudo copyfile jsontools)

source $ZSH/oh-my-zsh.sh

# mise (version manager)
eval "$($HOME/.local/bin/mise activate zsh)"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Oracle Skills CLI
export PATH="$HOME/.oracle-skills/bin:$PATH"

# === Fix Antigravity/VSCode Webview Error ===
fixanti() {
    echo "Searching and killing Antigravity processes..."
    pkill -f antigravity
    if [ $? -eq 0 ]; then
        echo "Antigravity processes killed."
    else
        echo "No running Antigravity processes found."
    fi
    vared -p "Do you want to clear Cache? (y/N): " -c answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo "Clearing Cache..."
        rm -rf ~/.config/Antigravity/Cache
        rm -rf ~/.config/Antigravity/Code\ Cache
        rm -rf ~/.config/Antigravity/GPUCache
        rm -rf ~/.config/Antigravity/Service\ Worker
        echo "Cache cleared."
    else
        echo "Cache kept."
    fi
}

# VPN aliases (credentials in ~/.zshrc.local)
alias vpn-on="echo \$VPN_PASSWORD | sudo openconnect --background --authgroup='1' --user=\$VPN_USER --passwd-on-stdin v1.nstda.or.th"
alias vpn-off="sudo killall -SIGINT openconnect"

# Load local secrets (not tracked by git)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
