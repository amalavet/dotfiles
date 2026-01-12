#!/bin/zsh

local SETUP_SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

ERROR='\033[0;31m[ERROR] '
WARN='\033[0;33m[WARN] '
NC='\033[0m' # No Color
OK='\033[0;32m[OK] '
INFO='\033[0;34m[INFO] '

# Use the appropriate package manager based on the OS
function install_packages_arch() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        if ! yay -Qi "$package" &>/dev/null; then
            echo -e "${OK}Installing $package...${NC}"
            sudo yay -S --noconfirm "$package"
        else
            echo -e "${INFO}$package is already installed${NC}"
        fi
    done
}

function install_packages_mac() {
    if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    local packages=("$@")
    for package in "${packages[@]}"; do
        if ! brew list | grep -q "^$package\$"; then
            echo -e "${OK}Installing $package...${NC}"
            brew install "$package"
        else
            echo -e "${INFO}$package is already installed${NC}"
        fi
    done
}

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_packages() {
        install_packages_arch "$@"
    }
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_packages() {
        install_packages_mac "$@"
    }
else
    echo -e "${ERROR}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

# Create .config directory if it doesn't exist
# --------------------------------------------
mkdir -p ~/.config

# GNU Stow for dotfiles management
# --------------------------------
install_packages stow
stow .

source ~/.zshrc

# Git
# ---
install_packages git
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_packages github-cli
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_packages gh
fi

git config --global core.editor "nvim"

source ~/.zshrc

# Curl
# ----
install_packages curl

source ~/.zshrc

# Alacritty
# ---------
install_packages alacritty

# Powerlevel10k
# -------------
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_packages zsh-theme-powerlevel10k
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_packages powerlevel10k
fi

# Zsh plugins
# -----------
install_packages zsh-syntax-highlighting
install_packages zsh-autosuggestions
install_packages zsh-vi-mode

# Fonts
# -----
# https://www.nerdfonts.com/cheat-sheet
# https://www.nerdfonts.com
if [[ "$OSTYPE" == "darwin"* ]]; then
    install_packages font-jetbrains-mono-nerd-font
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_packages ttf-jetbrains-mono-nerd
    fc-cache -fv >/dev/null
fi

# Node.js / NPM / Yarn
# -------
install_packages nvm yarn

# Go
# --
install_packages goenv
goenv global latest
source ~/.zshrc

# Install Delve (Go Debugger)
go install github.com/go-delve/delve/cmd/dlv@latest

# Python
# ------
install_packages pyenv
pyenv install 3.13 -s
pyenv global 3.13
source ~/.zshrc

# NeoVim
# ------
install_packages neovim ripgrep fzf fd

# Tmux
# ----
install_packages tmux
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Lazygit / Lazydocker
# -------
install_packages lazygit lazydocker

# Fastfetch
# ---------
install_packages fastfetch

# Opencode
# ---------
install_packages opencode
opencode github install

source ~/.zshrc
