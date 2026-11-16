---
name: md2gdrive
description: Publish a local Markdown file with mermaid and code blocks to Google Drive as an editable .md file, with each block rendered locally to an inline PNG. Use when the user asks to put a Markdown doc with mermaid diagrams in Drive or Google Docs, or to update one that is already there.
---

# md2gdrive

Run `~/dotfiles/md2gdrive.sh FILE.md [DRIVE_FILE_ID]`.

- With `DRIVE_FILE_ID`, the script replaces that Drive file. The ID and URL stay the same. Without it, the script creates a new file in My Drive and prints its `webViewLink`.
- The script renders each fenced block on this machine and replaces it with an inline `data:` PNG. Nothing goes to an online renderer.
  - ```` ```mermaid ````: `@mermaid-js/mermaid-cli` (theme `neutral`, look `neo`, Inter font) with the installed Chrome.
  - Other code: `silicon` (theme `GitHub`, JetBrains Mono). Languages that `silicon` does not know fall back: `cue` uses Go highlighting, and others use plain text.
- Keep the source `.md` as the file that you edit. The Drive file has only the images, so readers cannot copy the code.
- Docs removes smart chips, highlights, font colors, and HTML from `.md` files. Do not use them in the source.
- Markdown cannot set an image size. To change the size, change `-s 2` or add `-w <px>` in the script.
- Scan the source for secrets before an upload. Ask before you replace a file that another person owns.
