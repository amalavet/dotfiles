#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "usage: md2gdrive.sh FILE.md [DRIVE_FILE_ID]" >&2
  echo "  Renders each fenced block (mermaid with mermaid-cli, other code with silicon) to an inline PNG" >&2
  echo "  and uploads the result as a .md file to Drive. With DRIVE_FILE_ID, replaces that file." >&2
  exit 2
}

[[ $# -ge 1 && $# -le 2 && -f $1 ]] || usage
src=$1
file_id=${2:-}
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

echo '{"theme":"neutral","look":"neo","fontFamily":"Inter, -apple-system, Helvetica, Arial, sans-serif"}' >"$work/config.json"
chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
if [[ -x $chrome ]]; then
  echo "{\"executablePath\":\"$chrome\",\"headless\":\"new\"}" >"$work/puppeteer.json"
else
  echo '{}' >"$work/puppeteer.json"
fi

python3 - "$src" "$work" <<'EOF'
import re, sys
src, work = sys.argv[1], sys.argv[2]
blocks = re.findall(r"^```([\w+-]*)\n(.*?)\n```$", open(src).read(), re.M | re.S)
for i, (lang, body) in enumerate(blocks, 1):
    open(f"{work}/{i}.src", "w").write(body + "\n")
    open(f"{work}/{i}.lang", "w").write(lang)
print(f"{len(blocks)} code blocks, {sum(l == 'mermaid' for l, _ in blocks)} mermaid")
EOF

code_lang() {
  case $1 in
    cue | jsonnet) echo go ;;
    "" | text | txt | plain) echo log ;;
    *) echo "$1" ;;
  esac
}

for f in "$work"/*.src; do
  [[ -e $f ]] || break
  n=${f%.src}
  lang=$(<"$n.lang")
  if [[ $lang == mermaid ]]; then
    npx -y @mermaid-js/mermaid-cli@latest -q -p "$work/puppeteer.json" -c "$work/config.json" \
      -i "$f" -o "$n.png" -b white -s 2
  else
    for l in "$(code_lang "$lang")" log; do
      silicon -l "$l" --theme GitHub -b '#eaeef2' --no-window-controls --no-line-number \
        --pad-horiz 24 --pad-vert 24 --shadow-blur-radius 0 -f 'JetBrainsMono Nerd Font Mono; Menlo' \
        -o "$n.png" "$f" 2>/dev/null || true
      [[ -f $n.png ]] && break
    done
  fi
  [[ -f $n.png ]] || { echo "failed to render $f" >&2; exit 1; }
done

python3 - "$src" "$work" <<'EOF'
import base64, re, sys
src, work = sys.argv[1], sys.argv[2]
text = open(src).read()
refs = []
def render(m):
    n = len(refs) + 1
    kind = "diagram" if m[1] == "mermaid" else f"{m[1]} code" if m[1] else "code"
    refs.append(f"[block{n}]: <data:image/png;base64,{base64.b64encode(open(f'{work}/{n}.png', 'rb').read()).decode()}>")
    return f"![{kind} {n}][block{n}]"
text = re.sub(r"^```([\w+-]*)\n.*?\n```$", render, text, flags=re.M | re.S)
if refs:
    text = text.rstrip("\n") + "\n\n" + "\n\n".join(refs) + "\n"
open(f"{work}/out.md", "w").write(text)
EOF

name=$(basename "$src")
cd "$work"
fields='{"fields":"id,name,size,webViewLink","supportsAllDrives":true'
if [[ -n $file_id ]]; then
  gws drive files update --params "$fields,\"fileId\":\"$file_id\"}" \
    --upload out.md --upload-content-type text/markdown
else
  gws drive files create --params "$fields}" --json "{\"name\":\"$name\",\"mimeType\":\"text/markdown\"}" \
    --upload out.md --upload-content-type text/markdown
fi
