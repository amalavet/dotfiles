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

# Link zshrc
# ----------
# FIX: We can use GNU stow to manage dotfiles https://www.youtube.com/watch?v=06x3ZhwrrwA
if [ ! -L ~/.zshrc ]; then
    echo -e "${OK}Linking .zshrc${NC}"
    ln -s $SETUP_SCRIPT_PATH/.zshrc ~/.zshrc
fi

source ~/.zshrc

# Use the appropriate package manager based on the OS
function install_packages_arch() {
    local packages=("$@")
    for package in "${packages[@]}"; do
        if ! pacman -Qi "$package" &>/dev/null && ! yay -Qi "$package" &>/dev/null; then
            echo -e "${OK}Installing $package...${NC}"
            sudo pacman -S --noconfirm "$package" || yay -S --noconfirm "$package"
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

# Alacritty
# ---------
install_packages alacritty

if [ ! -L ~/.config/alacritty ]; then
    echo -e "${OK}Linking Alacritty config${NC}"
    ln -s $SETUP_SCRIPT_PATH/alacritty/ ~/.config/alacritty
fi

# Powerlevel10k
# -------------
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_packages zsh-theme-powerlevel10k
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_packages powerlevel10k
fi

if [ ! -L ~/.p10k.zsh ]; then
    echo -e "${OK}Linking Powerlevel10k config${NC}"
    ln -s $SETUP_SCRIPT_PATH/.p10k.zsh ~/.p10k.zsh
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
install_packages ttf-jetbrains-mono-nerd
fc-cache -fv >/dev/null

# Node.js / NPM
# -------
install_packages nodejs npm

# Go
# --
install_packages goenv
goenv global latest
source ~/.zshrc

# NeoVim
# ------
install_packages neovim ripgrep fzf fd

if [ ! -L ~/.config/nvim ]; then
    echo -e "${OK}Installing Neovim configuration${NC}"
    ln -s $SETUP_SCRIPT_PATH/nvim/ ~/.config/nvim
fi

# Tmux
# ----
install_packages tmux
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [ ! -L ~/.tmux.conf ]; then
    echo -e "${OK}Installing Tmux configuration"${NC}
    ln -s $SETUP_SCRIPT_PATH/.tmux.conf ~/.tmux.conf
fi

# Custom commands
# ---------------
if [ ! -L ~/cmds.zsh ]; then
    ln -s $SETUP_SCRIPT_PATH/cmds.zsh ~/cmds.zsh
fi

# Aerospace window manager
# -----
echo -e "${WARN}Please install Aerospace yourself${NC}"
if [ ! -L ~/.config/aerospace/aerospace.toml ]; then
    echo -e "${OK}Linking Aerospace config${NC}"
    mkdir -p ~/.config/aerospace
    ln -s $SETUP_SCRIPT_PATH/aerospace.toml ~/.config/aerospace/aerospace.toml
fi

# Yabai
# -----
echo -e "${WARN}Please install Yabai and skhd yourself${NC}"
if [ ! -L ~/.yabairc ]; then
    echo -e "${OK}Linking Yabai config${NC}"
    ln -s $SETUP_SCRIPT_PATH/.yabairc ~/.yabairc
fi

if [ ! -L ~/.skhdrc ]; then
    echo -e "${OK}Linking Skhd config${NC}"
    ln -s $SETUP_SCRIPT_PATH/.skhdrc ~/.skhdrc
fi

# Lazygit / Lazydocker
# -------
install_packages lazygit lazydocker

# Fastfetch
# ---------
install_packages fastfetch

source ~/.zshrc
