-- Hyprland config (lua, for v0.55+)
-- See https://wiki.hypr.land/Configuring/

local mainMod = "SUPER"

------------
-- MONITOR
------------
hl.monitor({ output = "DP-2", mode = "3440x1440@144", position = "0x0", scale = 1.0 })
hl.monitor({ output = "eDP-1", mode = "2880x1800@120", position = "760x1440", scale = 1.5, bitdepth = 10, cm = "hdr", sdrbrightness = 1.2, sdrsaturation = 1.0 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.5 })

-------------------
-- WORKSPACE RULES
-------------------
for i = 1, 5 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1", persistent = true })
end
for i = 6, 10 do
	hl.workspace_rule({ workspace = tostring(i), monitor = "DP-2", persistent = true })
end

------------
-- ENV VARS
------------
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

----------
-- CURSOR
----------
local cursor_theme = "catppuccin-mocha-red-cursors"
local cursor_size = 32
hl.env("HYPRCURSOR_THEME", cursor_theme)
hl.env("HYPRCURSOR_SIZE", tostring(cursor_size))
hl.env("XCURSOR_THEME", cursor_theme)
hl.env("XCURSOR_SIZE", tostring(cursor_size))
hl.exec_cmd("hyprctl setcursor " .. cursor_theme .. " " .. cursor_size)

------------------
-- AUTOSTART
------------------
hl.on("hyprland.start", function()
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
	hl.exec_cmd("dconf write /org/gnome/desktop/interface/color-scheme \"'prefer-dark'\"")
	hl.exec_cmd("uwsm app -- waybar")
	hl.exec_cmd("uwsm app -- hyprpaper")
	hl.exec_cmd("uwsm app -- hypridle")
	hl.exec_cmd("uwsm app -- mako")
	hl.exec_cmd("uwsm app -- poweralertd -s")
	hl.exec_cmd("uwsm app -- nm-sidebar --background")
	hl.exec_cmd("uwsm app -- elephant")
	hl.exec_cmd("uwsm app -- walker --gapplication-service")
	hl.exec_cmd("[workspace 2 silent] uwsm app -- google-chrome-stable")
	hl.exec_cmd("[workspace 3 silent] uwsm app -- alacritty -e zsh -lc 'tmux a || (source ~/.zshrc && :tmux); zsh'")
end)

----------
-- CONFIG
----------
hl.config({
	general = {
		gaps_in = 0,
		gaps_out = 0,
		border_size = 0,
		["col.active_border"] = "rgba(ffffff4d)",
		["col.inactive_border"] = "rgba(0000004d)",
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 0,
		rounding_power = 0,
		active_opacity = 1.0,
		inactive_opacity = 0.9,
		blur = {
			enabled = true,
			size = 3,
			passes = 1,
			vibrancy = 0.1696,
		},
	},

	animations = {
		enabled = false,
	},

	dwindle = {
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},

	input = {
		kb_layout = "us",
		kb_options = "caps:swapescape",
		follow_mouse = 1,
		repeat_delay = 200,
		repeat_rate = 50,
		sensitivity = -0.8,
		touchpad = {
			scroll_factor = 0.2,
			natural_scroll = false,
		},
	},

	xwayland = {
		force_zero_scaling = true,
	},

	cursor = {
		no_hardware_cursors = true,
		use_cpu_buffer = 1,
	},
})

-- Per-device input overrides
hl.device({ name = "asce1206:00-04f3:3315-touchpad", sensitivity = 0 })

-- Layer rule for waybar blur
hl.layer_rule({ match = { namespace = "notifications" }, blur = true })

-----------------
-- WINDOW RULES
-----------------
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

----------
-- BINDS
----------
hl.bind(mainMod .. " + return", hl.dsp.exec_cmd("uwsm app -- alacritty -e zsh -lc 'tmux a || (source ~/.zshrc && :tmux); zsh'"))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd("uwsm app -- walker"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Move focus
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Move window
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Resize
hl.bind(mainMod .. " + right", hl.dsp.window.resize({ x = 150, y = 0, relative = true }))
hl.bind(mainMod .. " + left", hl.dsp.window.resize({ x = -150, y = 0, relative = true }))
hl.bind(mainMod .. " + up", hl.dsp.window.resize({ x = 0, y = -150, relative = true }))
hl.bind(mainMod .. " + down", hl.dsp.window.resize({ x = 0, y = 150, relative = true }))

-- Workspaces
for i = 1, 9 do
	hl.bind(mainMod .. " + " .. i, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = true }))
end
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10, follow = true }))

-- Scroll workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse drag/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%+"),
	{ repeating = true, locked = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -d amdgpu_bl1 -e4 -n2 set 5%-"),
	{ repeating = true, locked = true }
)

-- Screenshot / record (mac-style)
hl.bind("ALT + SHIFT + 3", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
hl.bind("ALT + SHIFT + 4", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/record-toggle.sh"))

-- Media
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
