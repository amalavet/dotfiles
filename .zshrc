export TERM="alacritty"

# Homebrew
# --------
if [[ "$OSTYPE" == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Go
# --
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"
export PATH="$GOROOT/bin:$PATH"
export PATH="$PATH:$GOPATH/bin"

# Node.js
# -------
export NVM_DIR="$HOME/.nvm"
source $(brew --prefix nvm)/nvm.sh
source $(brew --prefix nvm)/etc/bash_completion.d/nvm

# Python
# ------
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# Aliases
alias vim="nvim"
alias vi="nvim"

# Set default git editor to nvim
git config --global core.editor "nvim"

# Commands
# --------
source "$HOME/cmds.zsh"

# ZSH Plugins
# -------------
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
elif [[ "$OSTYPE" == "darwin"* ]]; then
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
    source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
else
    echo -e "${ERROR}Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Zsh vim keybindings
# -------------------
bindkey -v
bindkey -M vicmd ":" undefined-key
KEYTIMEOUT=1

# History
# -------
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Bind accept one word at a time to shift+right
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(forward-word)
bindkey '\e[1;2C' forward-word
