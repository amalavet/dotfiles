# G14 Arch Setup

Manual steps `setup.zsh` can't do. Order matters.

Assumes Arch installed with `pacman`, `pacman-key` initialized, `yay`, and `gh` available.

## 1. ASUS g14 repo + asusctl

```sh
sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
# append to /etc/pacman.conf:
#   [g14]
#   Server = https://arch.asus-linux.org
sudo pacman -Suy
sudo pacman -S asusctl rog-control-center
```

## 2. NVIDIA (G14 GA403, hybrid)

```sh
sudo pacman -S nvidia-open-dkms vulkan-radeon lib32-vulkan-radeon mesa-utils
sudo systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume
sudo systemctl enable --now nvidia-powerd
```

`/etc/modprobe.d/nvidia.conf`:
```
options nvidia_drm modeset=1 fbdev=1
options nvidia NVreg_EnableS0ixPowerManagement=1 NVreg_DynamicPowerManagement=0x02 NVreg_PreserveVideoMemoryAllocations=1
```

Rebuild + reboot: `sudo mkinitcpio -P && sudo reboot`

`nvidia-laptop-power-cfg` is fine to install but check `/etc/modprobe.d/nvidia.conf` after install — `fbdev=0` tanks Hyprland to ~10fps. Force `fbdev=1` per the block above. Re-check after package updates.

## 3. MUX in Hybrid mode (required for brightness)

Panel must route through AMD iGPU or `amdgpu_bl1` backlight never registers and Fn brightness keys are dead.

```sh
asusctl armoury set gpu_mux_mode 1
reboot
```

## 4. Bootloader: systemd-boot + UKI

Kernel cmdline lives at `/etc/kernel/cmdline` (NOT `/etc/default/grub`). Rebuild UKIs after edits:

```sh
sudo mkinitcpio -P
```

Skip menu, default to g14 kernel — `/boot/loader/loader.conf`:
```
timeout 0
default arch-linux-g14.efi
```

Hold Space at boot to force menu. Change default: `sudo bootctl set-default <entry>.efi`.

## 5. Plymouth silent boot

```sh
sudo pacman -S plymouth
# /etc/mkinitcpio.conf: add `plymouth` to HOOKS (after udev or systemd)
# /etc/kernel/cmdline: append `quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0`
sudo mkinitcpio -P
```

Theme (default `bgrt` works; or pick another):
```sh
sudo plymouth-set-default-theme -R bgrt   # -R rebuilds UKIs
plymouth-set-default-theme -l             # list available
```

`RDSEED32 is broken` KERN_EMERG on Zen 5 — no software fix. `clearcpuid=rdseed` does NOT silence it (runtime test bypasses CPUID). Needs BIOS AGESA update (`fwupdmgr refresh && fwupdmgr get-updates`).

## 6. GDM theming

`gdm-settings` GUI. AUR build via `pyenv` shim breaks blueprint-compiler:
```sh
PATH=/usr/bin:$PATH yay -S gdm-settings
```
Re-apply after every gnome-shell/gdm update.

## 7. Hyprland

```sh
sudo pacman -S --needed hyprland hyprlock hypridle hyprpaper \
  mako poweralertd uwsm \
  brightnessctl wl-clipboard cliphist xclip
```

### Session via uwsm

Required — without it, xdg portals don't start (no screen sharing/recording).

Pick **"Hyprland (uwsm-managed)"** in GDM.

Wrap GUI app launches in `hyprland.lua`:
```lua
hl.exec_cmd("uwsm app -- waybar")
hl.exec_cmd("[workspace 2 silent] uwsm app -- google-chrome-stable")
```
Skip the wrap for one-shots (`hyprctl`, `gsettings`, `wpctl`, etc.).

### Portal routing

`~/.config/xdg-desktop-portal/hyprland-portals.conf`:
```ini
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.Notification=gtk
```

### Lua config (0.55+)

Auto-loaded from `~/.config/hypr/hyprland.lua`. Reload: `hyprctl reload`. Debug: `hyprctl configerrors`, logs at `$XDG_RUNTIME_DIR/hypr/<instance>/hyprland.log`.

LSP undefined `hl` — `~/.config/hypr/.luarc.json`:
```json
{ "diagnostics.globals": ["hl"] }
```

### Cursor / ghost cursor

```lua
hl.config({
  input = { sensitivity = -0.8 },
  cursor = { no_hardware_cursors = true, use_cpu_buffer = 1 },
})
hl.device({ name = "asce1206:00-04f3:3315-touchpad", sensitivity = 0 })
```

Ghost cursor still occurs intermittently despite the above. Likely a GDM↔Hyprland cursor handoff bug on NVIDIA ([thread](https://old.reddit.com/r/hyprland/comments/1tqhg4u/ghost_cursor_persistent/)). Reported fixes: swap GDM for sddm/ly, or toggle `no_hardware_cursors` twice.

Stuck cursor after GNOME↔Hyprland switch: `hyprctl setcursor Adwaita 24` (or `pkill Xwayland`).

Pink Catppuccin cursor: `yay -S catppuccin-cursors-mocha`, theme `catppuccin-mocha-pink-cursors`.

### Hyprpaper

Old syntax silently ignored. `~/.config/hypr/hyprpaper.conf`:
```
splash = false
wallpaper {
    monitor =
    path = ~/dotfiles/wallpaper.jpg
}
```

### Brightness keybinds (pin device — `nvidia_0` stub coexists)

```lua
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%+"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%-"), { repeating = true, locked = true })
```

### Notifications

Autostart in lua:
```lua
hl.exec_cmd("mako")
hl.exec_cmd("poweralertd -s")
```

Reload config: `makoctl reload`. Test: `notify-send "t" "b"` (`-u critical` sticky).

Chrome to mako (not gnome): portal config above + `chrome://flags/#enable-system-notifications` Enabled.

### Screenshots & recording

```sh
yay -S hyprshot gpu-screen-recorder
```

`Alt+Shift+3` screenshot region → clipboard. `Alt+Shift+4` toggles recording via `~/.config/hypr/scripts/record-{toggle,saved}.sh` (portal picker, `-sc` save hook fires "Saved" notification with filename).

Waybar `privacy` module shows red blinking pills for active screencast and mic, via PipeWire. Chrome flag `chrome://flags/#enable-webrtc-pipewire-camera` (Firefox: `media.webrtc.camera.allow-pipewire`) routes webcam through the portal so it also trips the screencast pill — no separate webcam module needed.

## 8. Hardware quirks

Disable G14 lid Slash LED:
```sh
asusctl slash --disable
```

Logitech G502:
```sh
sudo pacman -S piper libratbag
yay -S input-remapper-git
```
`piper` for DPI/profiles, `input-remapper-gtk` for keybinds/macros (enable Autoload per device).

## 9. OpenCode

- Transparent bg: theme `system` in `.config/opencode/tui.json`.
- Vim editing in prompt: install `vimcode` plugin pinned to `v0.12.2`. Full nvim compose via `/editor` (ctrl+x e).
- Caveman: `npx -y github:JuliusBrussee/caveman -- --only opencode --force`.

## Inspect OS state

```sh
# g14 repo
rg -A1 '^\[g14\]' /etc/pacman.conf

# NVIDIA modprobe (declared vs runtime)
cat /etc/modprobe.d/nvidia.conf
rg -i "fbdev|S0ix|DynamicPower" /proc/driver/nvidia/params

# kernel cmdline (declared vs active)
cat /etc/kernel/cmdline
cat /proc/cmdline

# initramfs hooks
rg ^HOOKS /etc/mkinitcpio.conf

# bootloader
cat /boot/loader/loader.conf
bootctl list
ls /boot/EFI/Linux/

# backlight
ls /sys/class/backlight/
brightnessctl info

# MUX state
asusctl armoury get gpu_mux_mode

# nvidia services
systemctl status nvidia-suspend nvidia-hibernate nvidia-resume nvidia-powerd

# plymouth theme
plymouth-set-default-theme
plymouth-set-default-theme -l

# AUR + asus pkgs installed
pacman -Qm
pacman -Qqs 'asusctl|^rog-'

# portal backends available
ls /usr/share/xdg-desktop-portal/portals/
```

## Pitfalls (do not repeat)

- `ttf-maple-mono-nf` — gone, use `maplemono-nf`.
- Editing `/etc/default/grub` — not used, bootloader is systemd-boot.
- `acpi_backlight=*`, `NVreg_EnableBacklightHandler=0`, `amdgpu.backlight=1` — none of these fix the OLED brightness; only the MUX flip does.
- `linux-g14` kernel install — not the fix for brightness.
- Hyprpaper old single-line `wallpaper = ,path` syntax — silently ignored in 0.8.x.
- Running `yay` with active pyenv shim — breaks blueprint-compiler builds. Prefix `PATH=/usr/bin:$PATH`.
- `wl-screenrec` AUR — broken vs current ffmpeg. Use `gpu-screen-recorder`.
- `pgrep -f gpu-screen-recorder` in a hyprland bind matches its own `sh -c`. Use `pidof` or `pgrep -x gpu-screen-reco` (15-char comm).
- `systemctl --user start graphical-session.target` refuses manual start. Use uwsm.
- Waybar `privacy` module's "screenshare" class fires on any PipeWire `VIDEO_INPUT` — not just screen captures. Webcam shows up too once Chrome/Firefox use pipewire-camera. No dedicated webcam type exists.
