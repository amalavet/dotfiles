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

# kubectl
function :k() {
    kubectl "$@"
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
    CGO_ENABLED=0 dlv $first_arg --headless --listen=:2345 --api-version=2 $second_arg -- "$@"
}

# Start a debug server for a python project
function :dbpy() {
    python -m debugpy --listen :2345 --wait-for-client $@
}

# Restart yabai
function :y() {
    yabai --restart-service
}

# Open a project in tmux, creating a new session if needed
function :to() {
    dir="$1"
    dir_name=$(basename "$dir")

    if tmux has-session -t $dir_name 2>/dev/null; then
        echo "Session $dir_name already exists. Attaching to it."
        tmux attach-session -t $dir_name
    else
        # Create a new tmux session with lazygit
        tmux new-session -s $dir_name -d -n "git" "cd $dir && lazygit; zsh"

        # Open nvim with two terminals
        tmux new-window -n "nvim" "cd $dir && nvim; zsh"
        tmux split-window -hb -t $dir_name:nvim "cd $dir; zsh"
        tmux split-window -v -t $dir_name:nvim "cd $dir; zsh"

        # Resize panes
        tmux select-pane -t 2
        tmux resize-pane -x 500

        # Attach to the new session
        tmux attach-session -t $dir_name
    fi
}

# Open all projects in tmux
function :tmux() {
    tmux kill-server

    GREEN='\033[0;32m'
    NC='\033[0m' # No Color

    echo -e "${GREEN}Opening tmux...${NC}"
    # Setup tmux sessions
    while read -r dir; do
        :to "$dir"
    done <"$HOME/tmux_sessions.txt"
    tmux new-session -s Docker -d -n "lazydocker" "lazydocker; zsh"
    tmux new-session -s AI -d -n "opencode" "opencode; zsh"
    tmux a -t dotfiles
}

# Open a project in tmux, fzf to select project
function :ta() {
    local dir
    dir=$(find ~/GitHub/Personal ~/GitHub -type d -maxdepth 1 2>/dev/null | fzf)
    :to "$dir"
}

# Search and kill a process
function :kill() {
    ps aux | fzf | awk '{print $2}' | xargs kill -9
}

# Delete all remote Git branches that don't have a local branch, optional argument to specify a prefix of a branch
function :dbr() {
    local prefix="$1"

    # Sync with remote to ensure local refs are up-to-date
    echo "\033[0;34mSyncing with remote...\033[0m"
    git fetch --prune origin > /dev/null 2>&1

    # Get all remote branches (without the origin/ prefix)
    local remote_branches=$(git branch -r | sed "s|  origin/||" | grep -v "HEAD")

    # Get all local branches
    local local_branches=$(git branch | sed 's/^[* ]*//')

    # Find remote branches that don't have a local counterpart
    local branches_to_delete=()
    for remote_branch in ${(f)remote_branches}; do
        # Skip if prefix is specified and branch doesn't match
        if [[ -n "$prefix" && ! "$remote_branch" =~ ^"$prefix" ]]; then
            continue
        fi

        # Check if local branch exists
        if ! echo "$local_branches" | grep -q "^${remote_branch}$"; then
            branches_to_delete+=("$remote_branch")
        fi
    done

    if [[ ${#branches_to_delete[@]} -eq 0 ]]; then
        echo "No remote branches to delete."
        return 0
    fi

    # Display branches that will be deleted
    echo "\033[0;33mThe following remote branches will be deleted:\033[0m"
    for branch in "${branches_to_delete[@]}"; do
        echo "  \033[0;31m$branch\033[0m"
    done

    # Confirm deletion
    echo -n "\n\033[0;33mProceed with deletion? (y/N): \033[0m"
    read confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Aborted."
        return 1
    fi

    # Delete branches
    for branch in "${branches_to_delete[@]}"; do
        echo "Deleting origin/$branch..."
        git push "origin" --delete "$branch"
    done

    echo "\n\033[0;32mDone!\033[0m"
}

# Fork a GitHub repository and set upstream
function :fork() {
    local repo="$1"

    if [[ -z "$repo" ]]; then
        echo "Error: Please provide a repository path (e.g., grafana/terraform-provider-grafana)"
        return 1
    fi

    # Extract owner/repo from URL if provided
    if [[ "$repo" =~ ^https?:// ]]; then
        repo=$(echo "$repo" | sed -E 's|^https?://[^/]+/||' | sed 's|\.git$||')
    fi

    echo "Forking $repo..."
    gh repo fork "$repo" --clone=true

    local repo_name="${repo##*/}"
    cd "$repo_name" || return 1

    echo "Setting upstream remote..."
    git remote add upstream "https://github.com/$repo.git"

    echo "Configuring fetch to pull from upstream..."
    git config remote.upstream.fetch "+refs/heads/*:refs/remotes/upstream/*"

    echo "Fetching from upstream..."
    git fetch upstream

    echo "\nDone! Repository forked and upstream configured."
    echo "You can now fetch upstream changes with: git fetch upstream"
}
