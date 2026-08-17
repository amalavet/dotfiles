# Returns a help list of all commands
function :h() {
    file="$HOME/cmds.zsh"
    echo "\033[0;34mAvailable commands:\033[0m"
    while IFS= read -r line; do
        if [[ $line == "# "* ]]; then
            description="${line:2}"
        elif [[ $line == "function :"* ]]; then
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

# Reload hyprland config and restart waybar (detached)
function :reload() {
    echo "\033[0;34mReloading hyprland...\033[0m"
    hyprctl reload >/dev/null
    echo "\033[0;34mRestarting waybar...\033[0m"
    pkill waybar
    sleep 0.3
    setsid -f uwsm app -- waybar </dev/null &>/dev/null
    echo "\033[0;32mDone.\033[0m"
}

# Starts a new tmux session for the given directory
function :ts() {
    dir="$1"
    session=$(basename "$dir")
    session=${session//[^a-zA-Z0-9_-]/-}

    if tmux has-session -t "=$session" 2>/dev/null; then
        echo "Session '$session' already exists."
        return
    fi

    # Create a new tmux session with lazygit
    tmux new-session -s $session -d -n "git" "cd $dir && lazygit; zsh"

    # Open nvim with two terminals
    if [[ "$session" == "dotfiles" ]]; then
        tmux new-window -n "nvim" "cd $dir; sleep 2; echo; echo; fastfetch; echo; echo; zsh"
    else
        tmux new-window -n "nvim" "cd $dir && nvim; zsh"
    fi
    tmux split-window -hb -t $session:nvim "cd $dir; zsh"
    tmux split-window -v -t $session:nvim "cd $dir; zsh"

    # Resize panes
    tmux select-pane -t 2
    tmux resize-pane -x 500
}

# List all project dirs (tmux_sessions.txt + GitHub dirs), optionally excluding those with active sessions
function _tmux_pick_dirs() {
    local exclude_active="${1:-false}"
    local existing_sessions=""
    [[ "$exclude_active" == "true" ]] && existing_sessions=$(tmux list-sessions -F '#S' 2>/dev/null)

    { [[ -f ~/tmux_sessions.txt ]] && cat ~/tmux_sessions.txt;
      find -L ~/GitHub/Personal ~/GitHub -maxdepth 1 -type d 2>/dev/null; } \
    | sort -u \
    | while IFS= read -r d; do
        if [[ "$exclude_active" == "true" ]]; then
            local name=${${d:t}//[^a-zA-Z0-9_-]/-}
            echo "$existing_sessions" | grep -qx "$name" && continue
        fi
        echo "$d"
      done \
    | fzf --multi \
        --prompt="Select sessions > " \
        --header="TAB to select multiple, ENTER to open" \
        --bind "ctrl-a:select-all"
}

# Open projects in tmux. Use ":tmux list" to pick with fzf, otherwise opens dirs from tmux_sessions.txt.
function :tmux() {
    if tmux list-sessions 2>/dev/null; then
        echo "\033[0;31mTmux is already running.\033[0m"
        return 1
    fi

    local selected
    if [[ "$1" == "list" ]]; then
        selected=$(_tmux_pick_dirs)
    else
        [[ -f ~/tmux_sessions.txt ]] && selected=$(cat ~/tmux_sessions.txt)
    fi
    [[ -z "$selected" ]] && return 0

    echo -e "\033[0;32mOpening tmux...\033[0m"
    while IFS= read -r dir; do
        :ts "$dir"
    done <<< "$selected"
    tmux new-session -s Docker -d -n "lazydocker" "lazydocker; zsh"

    local first
    first=$(basename "$(echo "$selected" | head -1)")
    first=${first//[^a-zA-Z0-9_-]/-}
    tmux a -t "$first"
}

# Attach to (or create) a project tmux session, skipping dirs that already have a session
function :ta() {
    local selected
    selected=$(_tmux_pick_dirs true)
    [[ -z "$selected" ]] && return 0

    local first session
    while IFS= read -r dir; do
        :ts "$dir"
        first=${first:-$dir}
    done <<< "$selected"

    session=$(basename "$first")
    session=${session//[^a-zA-Z0-9_-]/-}
    tmux a -t "$session"
}

# Make sure the default herdr workspaces (dotfiles, Docker) exist, then attach
function :herdr() {
    herdr workspace list >/dev/null 2>&1 || { (herdr server >/dev/null 2>&1 &) && sleep 1 }

    local ws pane
    if ! herdr workspace list 2>/dev/null | jq -e '.result.workspaces[] | select(.label == "dotfiles")' >/dev/null; then
        ws=$(herdr workspace create --cwd ~/dotfiles --label dotfiles --no-focus)
        herdr tab rename "$(echo "$ws" | jq -r '.result.tab.tab_id')" dotfiles >/dev/null
        herdr pane run "$(echo "$ws" | jq -r '.result.root_pane.pane_id')" lazygit >/dev/null
        pane=$(herdr tab create --workspace "$(echo "$ws" | jq -r '.result.workspace.workspace_id')" --cwd ~/dotfiles --label nvim --no-focus | jq -r '.result.root_pane.pane_id')
        herdr pane run "$(herdr pane split "$pane" --direction right --ratio 0.3 --cwd ~/dotfiles --no-focus | jq -r '.result.pane.pane_id')" fastfetch >/dev/null
        herdr pane split "$pane" --direction down --cwd ~/dotfiles --no-focus >/dev/null
    fi

    if ! herdr workspace list 2>/dev/null | jq -e '.result.workspaces[] | select(.label == "Docker")' >/dev/null; then
        herdr pane run "$(herdr workspace create --cwd ~ --label Docker --no-focus | jq -r '.result.root_pane.pane_id')" lazydocker >/dev/null
    fi

    herdr
}

# Snapshot herdr-resurrect state, then stop the server, so shutdown teardown
# events can't clobber the snapshot before it's saved
function :hstop() {
    herdr plugin action invoke save --plugin ntindle.herdr-resurrect >/dev/null 2>&1
    herdr server stop
}

# Stop herdr and wipe all of its state (workspaces, sessions, snapshots)
function :hpurge() {
    echo -n "\033[0;33mThis will stop herdr and delete all workspace state. Proceed? (y/N): \033[0m"
    read confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        return 1
    fi

    herdr session list 2>/dev/null | awk 'NR>1 {print $1}' | while IFS= read -r s; do
        herdr session stop "$s" >/dev/null 2>&1
    done
    herdr server stop >/dev/null 2>&1
    rm -f ~/.config/herdr/session.json ~/.config/herdr/*.log
    rm -rf ~/.config/herdr/sessions ~/.local/state/herdr
    echo "\033[0;32mHerdr purged.\033[0m"
}

# Search and kill a process
function :kill() {
    ps aux | fzf | awk '{print $2}' | xargs kill -9
}

# Delete my remote Git branches that don't have a local branch or open PR, pass a prefix to filter, or "all" for everyone's branches
function :dbr() {
    local prefix="$1"
    local my_email=""

    # Default to branches authored by me if no prefix provided
    if [[ -z "$prefix" ]]; then
        my_email=$(git config user.email)
    # If "all" is passed, use no prefix
    elif [[ "$prefix" == "all" ]]; then
        echo "\033[0;31mWARNING: You are about to delete ALL remote branches without a local counterpart!\033[0m"
        echo -n "\033[0;33mAre you sure you want to proceed? (y/N): \033[0m"
        read confirm_all
        if [[ "$confirm_all" != "y" && "$confirm_all" != "Y" ]]; then
            return 1
        fi
        prefix=""
    fi

    echo "\033[0;34mSyncing with remote...\033[0m"
    git fetch --prune origin >/dev/null 2>&1

    local remote_branches=$(git branch -r | sed "s|  origin/||" | grep -v "HEAD")
    local local_branches=$(git branch | sed 's/^[* ]*//')
    local pr_branches=$(gh pr list --state open --limit 200 --json headRefName --jq '.[].headRefName' 2>/dev/null)
    local my_branches=""
    if [[ -n "$my_email" ]]; then
        my_branches=$(git for-each-ref --format='%(refname:short) %(authoremail)' refs/remotes/origin \
            | awk -v e="<$my_email>" '$2 == e {sub("^origin/", "", $1); print $1}')
    fi
    local branches_to_delete=()

    for remote_branch in ${(f)remote_branches}; do
        if [[ -n "$prefix" && ! "$remote_branch" =~ ^"$prefix" ]]; then
            continue
        fi

        if [[ -n "$my_email" ]] && ! echo "$my_branches" | grep -q "^${remote_branch}$"; then
            continue
        fi

        if echo "$pr_branches" | grep -q "^${remote_branch}$"; then
            continue
        fi

        if ! echo "$local_branches" | grep -q "^${remote_branch}$"; then
            branches_to_delete+=("$remote_branch")
        fi
    done

    if [[ ${#branches_to_delete[@]} -eq 0 ]]; then
        echo "No remote branches to delete."
        return 0
    fi

    echo "\033[0;33mThe following remote branches will be deleted:\033[0m"
    for branch in "${branches_to_delete[@]}"; do
        echo " * \033[0;31m$branch\033[0m"
    done

    echo -n "\n\033[0;33mProceed with deletion? (y/N): \033[0m"
    read confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        return 1
    fi

    # Double confirmation if more than 10 branches
    if [[ ${#branches_to_delete[@]} -gt 10 ]]; then
        echo "\n\033[0;31mWARNING: You are about to delete ${#branches_to_delete[@]} branches!\033[0m"
        echo -n "\033[0;33mAre you absolutely sure? (y/N): \033[0m"
        read confirm_many
        if [[ "$confirm_many" != "y" && "$confirm_many" != "Y" ]]; then
            return 1
        fi
    fi

    git push origin --delete "${branches_to_delete[@]}"
    git fetch --prune origin >/dev/null 2>&1
}

# Setup AI agent markdown file for all subdirectories one level deep
# Usage: :ai [FILENAME.md] (default: AGENTS.md)
function :ai() {
    local target="${1:-AGENTS.md}"
    for dir in */; do
        [[ -d "$dir" ]] || continue
        if [[ -f "${dir}${target}" ]]; then
            echo "$dir: $target already exists."
        elif [[ -f "${dir}AGENTS.md" ]]; then
            ln -s "AGENTS.md" "${dir}${target}"
            echo "$dir: Created symlink: $target -> AGENTS.md"
        elif [[ -f "${dir}AGENT.md" ]]; then
            ln -s "AGENT.md" "${dir}${target}"
            echo "$dir: Created symlink: $target -> AGENT.md"
        else
            touch "${dir}${target}"
            echo "$dir: Created $target"
        fi
    done
}

# Update Arch system (official + AUR packages)
function :up() {
    yay -Syu "$@"
}

# Regenerate dotfiles/packages.txt from currently installed Arch packages
function :pkgs() {
    local file="$HOME/dotfiles/packages.txt"
    local header="# Generated by \`:pkgs\` (see cmds.zsh). Do not edit manually."
    chmod u+w "$file" 2>/dev/null
    { echo "$header"; pacman -Qqe; } > "$file"
    chmod 444 "$file"
    echo "\033[0;32mWrote $(pacman -Qqe | wc -l) packages to $file\033[0m"
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
