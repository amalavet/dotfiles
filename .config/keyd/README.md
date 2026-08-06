# keyd

```sh
yay -S keyd
sudo ln -sfn ~/dotfiles/etc/keyd/default.conf /etc/keyd/default.conf
sudo systemctl enable --now keyd
sudo usermod -aG keyd $USER
# log out + back in for group to take effect
systemctl --user enable --now keyd-application-mapper
```

If on GNOME, also clear any existing capslock swap:

```sh
gsettings set org.gnome.desktop.input-sources xkb-options "[]"
```
