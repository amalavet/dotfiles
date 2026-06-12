#!/usr/bin/env bash
# Toggle gpu-screen-recorder. Notify only once recording is actually live
# (output file grows, i.e. user finished the portal picker).
set -u

OUT_DIR="$HOME/Videos"
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
		notify-send -a Recording "Started $OUT"
		exit 0
	fi
	pidof gpu-screen-recorder >/dev/null || exit 0
	sleep 0.5
done
