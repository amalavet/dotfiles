#!/usr/bin/env python3
import json
import os
import re
import shlex
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from urllib.parse import unquote, urlparse

TOKEN = r'''[^\s"'`()\[\]<>|]'''
PATTERN = re.compile(rf"{TOKEN}*/{TOKEN}+(?::\d+(?::\d+)?)?|{TOKEN}+\.[A-Za-z0-9]+(?::\d+(?::\d+)?)?")
URL_PREFIXES = ("http://", "https://")


def main():
    {"start": start, "pick": pick, "preview": preview_target, "open": open_target}[sys.argv[1]]()


def start():
    context = json.loads(os.environ["HERDR_PLUGIN_CONTEXT_JSON"])
    pane = context["focused_pane_id"]
    cwd = context.get("focused_pane_cwd") or context.get("workspace_cwd") or os.getcwd()
    workspace = context["workspace_id"]
    herdr = os.environ.get("HERDR_BIN_PATH", "herdr")
    output = subprocess.run(
        [herdr, "pane", "read", pane, "--source", "recent-unwrapped", "--lines", "100", "--format", "text"],
        check=True,
        capture_output=True,
        text=True,
    ).stdout
    targets = scan(output, cwd)
    if not targets:
        return
    with tempfile.NamedTemporaryFile("w", prefix="herdr-open-hints-", suffix=".json", delete=False) as data:
        json.dump({"targets": targets, "cwd": cwd, "workspace": workspace}, data)
        data_file = data.name
    subprocess.run(
        [
            herdr,
            "plugin",
            "pane",
            "open",
            "--plugin",
            "alejandromalavet.open-hints",
            "--entrypoint",
            "picker",
            "--focus",
            "--env",
            f"HERDR_OPEN_HINTS_DATA={data_file}",
        ],
        check=True,
    )


def scan(output, cwd):
    targets = []
    seen = set()
    for line in reversed(output.splitlines()):
        for match in PATTERN.finditer(line):
            target = trim(match.group())
            if target and target not in seen and is_openable(target, cwd):
                seen.add(target)
                targets.append(target)
    return targets


def is_openable(target, cwd):
    if target.startswith(URL_PREFIXES):
        return bool(urlparse(target).hostname)
    path, _ = parse_path(target, cwd)
    return Path(path).is_file()


def trim(target):
    return target.rstrip(".,;!?").rstrip(":")


def pick():
    data_file = os.environ["HERDR_OPEN_HINTS_DATA"]
    try:
        with open(data_file) as data:
            payload = json.load(data)
        preview = shlex.join([sys.executable, __file__, "preview", "{}", payload["cwd"]])
        result = subprocess.run(
            [
                "fzf",
                "--layout=default",
                "--bind=left-click:accept",
                f"--preview={preview}",
                "--preview-window=up,60%,wrap,border-bottom",
            ],
            input="\n".join(payload["targets"]),
            text=True,
            stdout=subprocess.PIPE,
        )
        if result.returncode == 0:
            subprocess.Popen(
                [sys.executable, __file__, "open", result.stdout.rstrip("\n"), payload["cwd"], payload["workspace"]],
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
    finally:
        Path(data_file).unlink(missing_ok=True)


def preview_target():
    target, cwd = sys.argv[2:4]
    if target.startswith(URL_PREFIXES):
        print(target, end="")
        return
    path, selected_line = parse_path(target, cwd)
    command = ["bat", "--color=always", "--theme=ansi", "--style=numbers", "--paging=never"]
    if selected_line:
        line = int(selected_line)
        command += ["--highlight-line", str(line), "--line-range", f"{max(1, line - 20)}:{line + 100}"]
    command.append(path)
    os.execvp(command[0], command)


def open_target():
    time.sleep(0.15)
    target, cwd, workspace = sys.argv[2:5]
    try:
        if target.startswith(URL_PREFIXES):
            opener = "open" if sys.platform == "darwin" else "xdg-open"
            subprocess.Popen([opener, target], start_new_session=True)
            return
        path, line = parse_path(target, cwd)
        open_in_nvim(path, line, workspace)
    except Exception as error:
        state = Path(os.environ.get("HERDR_PLUGIN_STATE_DIR", tempfile.gettempdir()))
        state.mkdir(parents=True, exist_ok=True)
        (state / "error.log").write_text(f"{error}\n")


def parse_path(target, cwd):
    if target.startswith("file:"):
        uri = urlparse(target)
        path = f"//{uri.netloc}{uri.path}" if uri.netloc and uri.netloc != "localhost" else uri.path
        target = unquote(path)
    target = target.replace("${PWD}", cwd).replace("$PWD", cwd)
    target = os.path.expandvars(target)
    line = None
    match = re.search(r":(\d+)(?::\d+)?$", target)
    if match:
        line = match.group(1)
        target = target[: match.start()]
    path = Path(target).expanduser()
    if not path.is_absolute():
        path = Path(cwd) / path
    return str(path.resolve()), line


def open_in_nvim(path, line, workspace):
    herdr = os.environ.get("HERDR_BIN_PATH", "herdr")
    panes = run_json([herdr, "pane", "list", "--workspace", workspace])["result"]["panes"]
    for pane in panes:
        info = run_json([herdr, "pane", "process-info", "--pane", pane["pane_id"]])
        processes = info["result"]["process_info"].get("foreground_processes", [])
        if processes and processes[0].get("name") == "nvim":
            nvim_pane = pane["pane_id"]
            break
    else:
        raise RuntimeError(f"no nvim pane found in workspace {workspace}")
    escaped = path.replace("'", "''")
    command = f":execute 'edit ' . fnameescape('{escaped}')"
    if line:
        command += f" | {line}"
    subprocess.run([herdr, "pane", "send-text", nvim_pane, command], check=True)
    subprocess.run([herdr, "pane", "send-keys", nvim_pane, "enter"], check=True)
    subprocess.run([herdr, "pane", "zoom", nvim_pane, "--off"], check=True)


def run_json(command):
    return json.loads(subprocess.run(command, check=True, capture_output=True, text=True).stdout)


if __name__ == "__main__":
    main()
