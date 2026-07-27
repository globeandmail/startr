#!/usr/bin/env python3
"""Splice generated changelog content into the release note template.

Reads:
  - .github/release-template.md  (the template)
  - /tmp/generated-changelog.md  (output of `gh api releases/generate-notes`)

Writes:
  - /tmp/release-notes.md

Environment variables:
  VERSION  The release version string, e.g. "1.2.0" (without the leading "v").
"""

import os
import sys

VERSION_PLACEHOLDER = "{version}"
CHANGELOG_PLACEHOLDER = "<!-- Describe changes in this release -->"

version = os.environ.get("VERSION", "")
if not version:
    print("ERROR: VERSION environment variable is not set.", file=sys.stderr)
    sys.exit(1)

with open(".github/release-template.md", encoding="utf-8") as f:
    template = f.read()

if VERSION_PLACEHOLDER not in template:
    print(f"ERROR: placeholder '{VERSION_PLACEHOLDER}' not found in release template.", file=sys.stderr)
    sys.exit(1)

if CHANGELOG_PLACEHOLDER not in template:
    print(f"ERROR: placeholder '{CHANGELOG_PLACEHOLDER}' not found in release template.", file=sys.stderr)
    sys.exit(1)

with open("/tmp/generated-changelog.md", encoding="utf-8") as f:
    generated = f.read().strip()

result = (
    template
    .replace(VERSION_PLACEHOLDER, version)
    .replace(CHANGELOG_PLACEHOLDER, generated)
)

with open("/tmp/release-notes.md", "w", encoding="utf-8") as f:
    f.write(result)
