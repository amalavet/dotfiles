#!/usr/bin/env bash
# Called by gpu-screen-recorder via -sc. Args: $1=filepath, $2=type.
notify-send -a Recording "Saved" "$(basename "$1")"
