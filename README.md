# dotfiles

1. The .zshrc is not automatically symlinked. Source it in your existing .zshrc, this is because there could be system specific settings you want to keep in your .zshrc in addition to the settings in this repo.
2. Use gnu stow to symlink the files in this repo to your home directory.
3. Pi is the default coding agent. Its global config is stowed from `.pi/agent`; authentication and sessions remain local.
4. On Arch G14, see [setup.md](setup.md) for one-time manual steps `setup.zsh` doesn't cover (MUX flip, GDM theming, hyprland lua gotchas, etc).

