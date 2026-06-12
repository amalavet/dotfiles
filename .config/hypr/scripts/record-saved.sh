#!/usr/bin/env bash
# Called by gpu-screen-recorder via -sc. Args: $1=filepath, $2=type.
rm -f /tmp/gsr-active
notify-send -a Recording "Saved" "$(basename "$1")"
