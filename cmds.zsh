# Returns a help list of all commands
function :h() {
    file="$HOME/cmds.zsh"
    echo "\033[0;34mAvailable commands:\033[0m"
    while IFS= read -r line; do
        if [[ $line == "# "* ]]; then
            description="${line:2}"
        elif [[ $line == "function "* ]]; then
            cmd="${line:9}"
            cmd=${cmd%%\(*}
            cmd=$(printf "  %-8s" "$cmd")
            echo -e "\033[1;32m\033[1m$cmd\033[0m- $description"
            description=""
        fi
    done <"$file"
}

# Put my laptop to sleep
function :sleep() {
    pmset sleepnow
}

# Open nvim
function :n() {
    nvim "$@"
}

# Source zshrc
function :s() {
    source ~/.zshrc
}

# Reset terminal
function :r() {
    reset
}

# Start a debug server for a go project, use debug or test as first argument
function :dlv() {
    first_arg=$1
    second_arg=$2
    shift
    shift
    CGO_ENABLED=0 dlv $first_arg --headless --listen=:12345 --api-version=2 $second_arg -- "$@"
}

# Start a debug server for a python project
function :dbpy() {
    python -m debugpy --listen :12345 --wait-for-client $@
}

# Restart yabai
function :y() {
    yabai --restart-service
}

# Open all projects in tmux, use --nosplit to open without panes
function :tmux() {
    tmux kill-server

    GREEN='\033[0;32m'
    NC='\033[0m' # No Color

    with_panes="true"

    # Check if --split flag was passed
    if [[ $1 == "--nosplit" ]]; then
        with_panes="false"
    fi

    echo -e "${GREEN}Opening tmux...${NC}"
    # Setup tmux sessions
    while read -r dir; do
        dir_name=$(basename "$dir")

        # Create a new window for lazygit
        tmux new-session -s $dir_name -d -n "git" "cd $dir && lazygit; zsh"

        # Create a window for neovim
        tmux new-window -n "nvim" "cd $dir && nvim; zsh"

        if [[ $with_panes == "true" ]]; then
            tmux split-window -h -t $dir_name:nvim "cd $dir; zsh"
            tmux split-window -v -t $dir_name:nvim "cd $dir; zsh"
            tmux select-pane -t 0
            tmux resize-pane -x 120
            tmux resize-pane -Z
        else
            tmux new-window -n "zsh" "cd $dir; zsh"
        fi
    done <"$HOME/tmux_sessions.txt"
    tmux new-session -s Docker -d -n "lazydocker" "lazydocker; zsh"
    tmux a -t dotfiles
}

# Open a project in tmux, fzf to select project
function :ta() {
    local dir
    dir=$(find ~/GitHub/Coinbase ~/GitHub/Personal ~/GitHub -type d -maxdepth 1 2>/dev/null | fzf)
    dir_name=$(basename "$dir")

    if tmux has-session -t $dir_name 2>/dev/null; then
        echo "Session $dir_name already exists. Attaching to it."
        tmux attach-session -t $dir_name
    else
        tmux new-session -s $dir_name -d -n "git" "cd $dir && lazygit; zsh"
        tmux new-window -n "nvim" "cd $dir && nvim; zsh"
        tmux split-window -h -t $dir_name:nvim "cd $dir; zsh"
        tmux split-window -v -t $dir_name:nvim "cd $dir; zsh"
        tmux select-pane -t 0
        tmux resize-pane -x 120
        tmux resize-pane -Z
        tmux attach-session -t $dir_name
    fi
}

# Search and kill a process
function :kill() {
    ps aux | fzf | awk '{print $2}' | xargs kill -9
}

# Delete all remote Git branches that don't have a local branch
function :rmbr() {
    local prefix="$1"
    
    echo "Fetching latest remote information..."
    git fetch --prune
    
    echo "\nIdentifying remote branches without local counterparts..."
    # Get all remote branches (excluding HEAD), strip "origin/" prefix
    git branch -r | grep -v "HEAD" | sed 's/origin\///' | while read -r remote_branch; do
        # Skip if a prefix is specified and branch doesn't match the prefix
        if [[ -n "$prefix" && ! "$remote_branch" == "$prefix"* ]]; then
            continue
        fi
        
        # Check if there's a local branch with the same name
        if ! git show-ref --verify --quiet refs/heads/"$remote_branch"; then
            echo "Deleting remote branch: $remote_branch"
            git push origin --delete "$remote_branch"
        fi
    done
    
    echo "\nCleaning untracked files from local repository..."
    git clean -fd
    
    echo "\nDone!"
}
