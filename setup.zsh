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
            # PATH=/usr/bin prefix bypasses pyenv shim so system python is used;
            # AUR builds like gdm-settings/blueprint-compiler fail under pyenv's python.
            PATH=/usr/bin:$PATH yay -S --noconfirm "$package"
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

# ASUS g14 repo (asusctl, rog-control-center, linux-g14)
# ------------------------------------------------------
if [[ "$OSTYPE" == "linux-gnu"* ]] && ! grep -q '^\[g14\]' /etc/pacman.conf; then
    echo -e "${OK}Adding asus-linux g14 repo...${NC}"
    sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
    sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
    printf '\n[g14]\nServer = https://arch.asus-linux.org\n' | sudo tee -a /etc/pacman.conf >/dev/null
    sudo pacman -Suy --noconfirm
fi

# Bulk install Arch packages
# --------------------------
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_packages $(grep -v '^\s*#' "$SETUP_SCRIPT_PATH/packages.txt" | grep -v '^\s*$')
fi

# G14 system config (NVIDIA + Plymouth)
# -------------------------------------
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    local rebuild_initramfs=0

    # NVIDIA modprobe (correct for MUX/Ultimate mode; overrides nvidia-laptop-power-cfg's bad fbdev)
    local nvidia_conf='/etc/modprobe.d/nvidia.conf'
    local nvidia_want='options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_EnableS0ixPowerManagement=1 NVreg_DynamicPowerManagement=0x02 NVreg_PreserveVideoMemoryAllocations=1'
    if [[ "$(sudo cat $nvidia_conf 2>/dev/null)" != "$nvidia_want" ]]; then
        echo -e "${OK}Writing $nvidia_conf...${NC}"
        echo "$nvidia_want" | sudo tee "$nvidia_conf" >/dev/null
        rebuild_initramfs=1
    fi
    sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service nvidia-powerd.service &>/dev/null

    # Plymouth: insert hook after udev/systemd
    if ! grep -q '^HOOKS=.*\bplymouth\b' /etc/mkinitcpio.conf; then
        echo -e "${OK}Adding plymouth to mkinitcpio HOOKS...${NC}"
        sudo sed -i -E 's/^(HOOKS=\([^)]* (udev|systemd))/\1 plymouth/' /etc/mkinitcpio.conf
        rebuild_initramfs=1
    fi

    # Silent boot flags in kernel cmdline
    local cmdline=$(cat /etc/kernel/cmdline 2>/dev/null)
    local missing=()
    for flag in quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0; do
        [[ $cmdline == *"$flag"* ]] || missing+=("$flag")
    done
    if (( ${#missing[@]} > 0 )); then
        echo -e "${OK}Appending silent boot flags to /etc/kernel/cmdline: ${missing[*]}${NC}"
        printf '%s %s\n' "$cmdline" "${missing[*]}" | sudo tee /etc/kernel/cmdline >/dev/null
        rebuild_initramfs=1
    fi

    if (( rebuild_initramfs )); then
        echo -e "${OK}Rebuilding initramfs (UKIs)...${NC}"
        sudo mkinitcpio -P
    fi
fi

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

# Symlink OS-specific alacritty overrides
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ln -sf "$SETUP_SCRIPT_PATH/.config/alacritty/linux.toml" ~/.config/alacritty/os.toml
elif [[ "$OSTYPE" == "darwin"* ]]; then
    ln -sf "$SETUP_SCRIPT_PATH/.config/alacritty/mac.toml" ~/.config/alacritty/os.toml
fi

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
    install_packages font-iosevka-nerd-font
    install_packages font-maple-mono-nf
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    install_packages ttf-jetbrains-mono-nerd
    install_packages ttf-iosevka-nerd
    install_packages maplemono-nf
    fc-cache -fv >/dev/null
fi

# Node.js / NPM / Yarn
# -------
install_packages nvm yarn

# Go
# --
install_packages goenv
goenv install latest -s
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

# jq
# --
install_packages jq

# Scooter
# -------
install_packages scooter

# Fastfetch
# ---------
install_packages fastfetch

# Opencode
# ---------
install_packages opencode
opencode github install

source ~/.zshrc
