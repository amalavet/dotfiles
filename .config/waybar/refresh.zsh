#!/bin/bash
CONFIG_FILE="$HOME/.config/waybar/config.jsonc"
STYLE_FILE="$HOME/.config/waybar/style.css"
trap "killall waybar" EXIT
while true; do
    inotifywait -e modify $CONFIG_FILE
    killall waybar
    waybar &
done &

while true; do
    inotifywait -e modify $STYLE_FILE
    killall waybar
    waybar &
done
