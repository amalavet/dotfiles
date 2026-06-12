#!/usr/bin/env bash
# Toggle gpu-screen-recorder. Notifications only fire once recording is
# actually live (output file growing), not when the portal picker pops.
set -u

OUT_DIR="$HOME/Videos"
FLAG="/tmp/gsr-active"
mkdir -p "$OUT_DIR"

if pidof gpu-screen-recorder >/dev/null; then
	pkill -INT -x gpu-screen-reco
	exit 0
fi

OUT="$OUT_DIR/rec-$(date +%Y%m%d-%H%M%S).mp4"
ON_SAVE="$HOME/.config/hypr/scripts/record-saved.sh"

setsid -f gpu-screen-recorder -w portal -f 60 -sc "$ON_SAVE" -o "$OUT" >/dev/null 2>&1

for _ in $(seq 1 120); do
	if [[ -s "$OUT" ]]; then
		touch "$FLAG"
		notify-send -a Recording "Started"
		exit 0
	fi
	pidof gpu-screen-recorder >/dev/null || exit 0
	sleep 0.5
done
