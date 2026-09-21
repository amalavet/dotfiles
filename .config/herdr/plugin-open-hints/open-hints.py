#!/usr/bin/env python3
import json
import os
import re
import subprocess
import sys
from pathlib import Path

HERDR = os.environ.get("HERDR_BIN_PATH") or str(Path.home() / ".local/bin/herdr")
TOKEN = r'''[^\s"'`()\[\]<>|]'''
PATTERN = re.compile(rf"{TOKEN}*/{TOKEN}+(?::\d+(?::\d+)?)?|{TOKEN}+\.[A-Za-z0-9]+(?::\d+(?::\d+)?)?")


def run(*args):
    return subprocess.run([HERDR, *args], check=True, capture_output=True, text=True).stdout


def herdr(*args):
    return json.loads(run(*args))["result"]


def stitch(lines, i):
    line = lines[i].rstrip()
    for nxt in lines[i + 1 : i + 4]:
        nxt = re.sub(r"^[\s│┃|>]*", "", nxt).rstrip()
        head = nxt.split(" ", 1)[0]
        if not head or head.startswith("http"):
            break
        line += head
        if " " in nxt:
            break
    return line


def parse(target, cwd):
    match = re.search(r":(\d+)(?::\d+)?$", target)
    path = Path(os.path.expandvars(target[: match.start()] if match else target)).expanduser()
    return str((Path(cwd) / path).resolve()), match and match.group(1)


def openable(target, cwd):
    return target.startswith("http") or Path(parse(target, cwd)[0]).is_file()


def find(clicked, pane, cwd):
    lines = run("pane", "read", pane, "--source", "recent-unwrapped", "--lines", "100").splitlines()
    for i in reversed(range(len(lines))):
        for m in PATTERN.finditer(stitch(lines, i)):
            target = m.group().rstrip(".,;!?:")
            if clicked in target and openable(target, cwd):
                return target


def open_target(target, cwd, workspace):
    if target.startswith("http"):
        return subprocess.Popen(["open" if sys.platform == "darwin" else "xdg-open", target])
    path, line = parse(target, cwd)
    for pane in herdr("pane", "list", "--workspace", workspace)["panes"]:
        procs = herdr("pane", "process-info", "--pane", pane["pane_id"])["process_info"].get("foreground_processes", [])
        if procs and procs[0].get("name") == "nvim":
            break
    else:
        sys.exit(f"open-hints: no nvim pane in {workspace}")
    escaped = re.sub(r"""([ \t*?\[{`$\\%#'"|!<])""", r"\\\1", path)
    run("pane", "send-text", pane["pane_id"], f":e +{line} {escaped}" if line else f":e {escaped}")
    run("pane", "send-keys", pane["pane_id"], "enter")
    run("pane", "zoom", pane["pane_id"], "--off")


def main():
    clicked = re.split(r"[│┃▕▏]", sys.argv[1])[0].strip().rstrip(".,;!?:")
    snap = herdr("api", "snapshot")["snapshot"]
    panes = [p for p in snap["panes"] if p["workspace_id"] == snap["focused_workspace_id"]]
    panes.sort(key=lambda p: p["pane_id"] != snap["focused_pane_id"])
    for pane in panes:
        cwd = pane.get("foreground_cwd") or pane.get("cwd") or os.getcwd()
        target = find(clicked, pane["pane_id"], cwd)
        if target:
            return open_target(target, cwd, pane["workspace_id"])
    cwd = panes[0].get("foreground_cwd") or os.getcwd()
    if openable(clicked, cwd):
        return open_target(clicked, cwd, panes[0]["workspace_id"])
    sys.exit(f"open-hints: nothing openable for {clicked!r}")


main()
