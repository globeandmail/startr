#!/usr/bin/env python3
"""Extract the 'What's new' section from a GitHub PR body and combine it
with the auto-generated PR changelog.

Reads the PR body from stdin. If a '## What's new' section is found,
outputs the curated bullets followed by the raw PR list (read from
/tmp/generated-changelog.md) wrapped in a <details> block. Exits with
no output if the section is not found, leaving the raw changelog untouched.
"""

import re
import sys

body = sys.stdin.read()
m = re.search(
    r"(?i)##\s+What.s\s+new\s*\n(.*?)(?=\n##|\n---|\Z)",
    body,
    re.DOTALL,
)
if not m:
    sys.exit(0)

# Strip trailing boilerplate (e.g. "🤖 Generated with [Claude Code](...)")
content = m.group(1).strip()
content = re.sub(r"\n*🤖.*$", "", content, flags=re.DOTALL).strip()
if not content:
    sys.exit(0)

try:
    with open("/tmp/generated-changelog.md", encoding="utf-8") as f:
        raw = f.read().strip()
except OSError:
    raw = ""

if raw:
    print(f"{content}\n\n<details>\n<summary>Details</summary>\n\n{raw}\n\n</details>")
else:
    print(content)
