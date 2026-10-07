# Dotfiles

This repository contains my development environment for macOS and Arch Linux.
The Arch configuration targets an ASUS ROG Zephyrus G14.

Zsh, Alacritty, Herdr, Neovim, and Pi form the main development workflow.
Tokyo Night is the shared theme for the terminal, editor, workspaces, and coding agent.

## Main parts

| Part | Purpose | Configuration |
| --- | --- | --- |
| Zsh | Shell commands, Vim keybindings, suggestions, and the Powerlevel10k prompt. | [.zshrc](.zshrc), [cmds.zsh](cmds.zsh), [.p10k.zsh](.p10k.zsh) |
| Alacritty | Terminal with JetBrains Mono Nerd Font and separate settings for each operating system. | [.config/alacritty](.config/alacritty) |
| Herdr | Terminal panes, project workspaces, and agent status. | [.config/herdr](.config/herdr), [.sessionizer](.sessionizer) |
| Neovim | Code search, language servers, completion, formatting, Git tools, tests, and debugging. | [.config/nvim](.config/nvim) |
| Pi | Coding agent with shared instructions, extensions, skills, and external tool connections. | [.pi/agent](.pi/agent) |
| Arch desktop | Hyprland manages windows. Waybar shows system status. Walker launches applications. Mako shows notifications. | [.config/hypr](.config/hypr), [.config/waybar](.config/waybar), [.config/walker](.config/walker), [.config/mako](.config/mako) |
| macOS desktop | AeroSpace manages windows and numbered workspaces. | [.config/aerospace](.config/aerospace) |
| Keyboard | Karabiner and keyd exchange Caps Lock and Escape. The repository also contains Glove80 layouts and firmware. | [.config/karabiner](.config/karabiner), [etc/keyd](etc/keyd), [keyboard](keyboard) |
| Other tools | Settings for K9s, Lazygit, and Scooter. | [.config/k9s](.config/k9s), [.config/lazygit](.config/lazygit), [.config/scooter](.config/scooter) |

## Development workflow

Herdr groups terminals into project workspaces.
Its project selector searches `~/GitHub`, `~/GitHub/Personal`, and `~` for Git repositories.
The default project layout contains a Lazygit tab and a Neovim tab with two shell panes.
See the [project selector settings](.config/herdr/plugins/config/sessionizer/config.toml) for the search paths and layout.

Neovim sends files and selected text to Pi through Sidekick.
When both tools share a Herdr tab, Neovim can open files that Pi changes through its `edit` and `write` tools.
Test commands use a separate Herdr pane, or an embedded terminal outside Herdr.

Inside Herdr, Alacritty file links open in a Neovim pane in the current workspace.
Web links open in the browser.

### Common shortcuts

In Herdr, press `Ctrl+B`. Release the keys. Then press the action key.
In Neovim, the leader key is `Space`.
Use the Neovim shortcuts in normal mode unless the table specifies another mode.

| Tool | Keys | Action |
| --- | --- | --- |
| Herdr | `Ctrl+B`, then `s` | Open the project selector. |
| Herdr | `Ctrl+B`, then `a` | Select an agent pane. |
| Herdr | `Ctrl+H/J/K/L` | Move focus left, down, up, or right. |
| Neovim | `Space ff` | Find a file. |
| Neovim | `Space fl` | Open Scooter for search and replace. |
| Neovim | `Space o` | Open the Oil file browser. |
| Neovim | `Space fm` | Format the current file. |
| Neovim | `Space t` / `Space T` | Run the nearest test or all tests in the file. |
| Neovim | `Space ai` | Show or hide Pi. |
| Neovim | `Space af` / `Space av` | Send the file or a visual selection to Pi. Use visual mode for `av`. |
| Neovim | `Space Space p` | Enable or disable automatic file display from Pi. |

Hyprland uses `Super+H/J/K/L` to move window focus.
AeroSpace uses `Alt+H/J/K/L` for the same directions.

## Setup

Use `~/dotfiles` as the repository path.
Several shell commands and desktop settings expect this location.
Save copies of existing configuration files before you continue.

### Link the configuration

These steps create configuration links, but do not install applications.
Install Git, Zsh, and [GNU Stow](https://www.gnu.org/software/stow/) first.

1. Clone the repository.

   ```sh
   git clone https://github.com/amalavet/dotfiles.git "$HOME/dotfiles"
   cd "$HOME/dotfiles"
   ```

2. Preview the links.

   ```sh
   stow --simulate --verbose --no-folding --target="$HOME" .
   ```

3. Move any conflicting files to a backup directory. Then create the links.

   ```sh
   stow --no-folding --target="$HOME" .
   ```

   Stow links files in your home directory to this repository.
   The `--no-folding` option prevents Stow from linking whole directories.

4. Create Alacritty's `os.toml` link. Run only the command for your operating system.

   macOS:

   ```sh
   ln -s "$HOME/dotfiles/.config/alacritty/mac.toml" "$HOME/.config/alacritty/os.toml"
   ```

   Arch Linux:

   ```sh
   ln -s "$HOME/dotfiles/.config/alacritty/linux.toml" "$HOME/.config/alacritty/os.toml"
   ```

5. Add this line to your existing `~/.zshrc`.

   ```sh
   source "$HOME/dotfiles/.zshrc"
   ```

   Stow excludes `.zshrc` to preserve your local shell settings.
   The shared shell configuration requires Goenv, Pyenv, Powerlevel10k, and the Zsh plugins in [setup.zsh](setup.zsh).
   On macOS, it also expects Homebrew at `/opt/homebrew` and the NVM version manager for Node.js.

Neovim requires [version 0.12 or later](https://neovim.io/doc/user/news-0.12/) for its built-in `vim.pack` plugin manager.
The first start installs plugins and missing tools from the Mason configuration.

### Install tools with the setup script

[setup.zsh](setup.zsh) is a personal setup script, not a general installer.
It uses Homebrew on macOS and `yay` on Arch Linux.
It also creates Stow links, selects the Alacritty settings, and installs Pi and Herdr integrations.

Review the script before use.
It runs downloaded installers and changes your global Git editor to Neovim.
On Arch, it can add the ASUS package repository and run a system upgrade.
It expects `npm` to be available. Arch also requires `yay` and an initialized pacman keyring.

Run it from the repository directory:

```sh
cd "$HOME/dotfiles"
zsh ./setup.zsh
```

The script asks before it installs all packages from [packages.txt](packages.txt).
That file records explicitly installed Arch packages. It is not a minimum dependency list.

Use [setup.md](setup.md) for the remaining G14 hardware, graphics, boot, and Hyprland session steps.
Install NVM and AeroSpace separately on macOS.
Use the [keyd instructions](.config/keyd/README.md) to install the Linux keyboard service.
Stow does not install files into `/etc/keyd`.

## Shell helpers

Run `:h` in Zsh to see all commands from [cmds.zsh](cmds.zsh).

| Command | Action |
| --- | --- |
| `:herdr` | Create the default `dotfiles` and `Docker` workspaces if needed, then attach to Herdr. |
| `:n` | Open Neovim. |
| `:s` | Reload `~/.zshrc`. |
| `:reload` | Reload Hyprland and restart Waybar on Arch. |
| `:pkgs` | Regenerate `packages.txt` from the installed Arch packages. |
| `:bpkgs` | Regenerate `brew_pkgs.txt` from the installed Homebrew formulae and casks. |

## Adapt the configuration

- Change monitor names, workspace assignments, and the backlight device in [.config/hypr/hyprland.lua](.config/hypr/hyprland.lua) for different hardware.
- Change editor options in [opts.lua](.config/nvim/lua/opts.lua). Change shortcuts in [remap.lua](.config/nvim/lua/remap.lua). Plugin settings live in [lua/plugins](.config/nvim/lua/plugins).
- Change Pi's model and packages in [settings.json](.pi/agent/settings.json). Review its [external tool connections](.pi/agent/mcp.json) before use. Use `/login` inside Pi to authenticate.
- Use [.stow-local-ignore](.stow-local-ignore) to control link exclusions. Git ignore rules do not control Stow.
- Keep credentials and session history out of Git.
