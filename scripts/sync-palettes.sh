#!/usr/bin/env bash

set -euo pipefail

TARGET_DIR="./palettes"
TMP_CLONE=$(mktemp -d)

echo "Fetching latest tinted-theming base16 schemes..."

git clone --depth 1 https://github.com/tinted-theming/schemes.git "$TMP_CLONE" &>/dev/null

mkdir -p "$TARGET_DIR"

echo "Processing and formatting palettes into '$TARGET_DIR'..."

for yaml in "$TMP_CLONE/base16"/*.yaml; do
	[ -e "$yaml" ] || continue
	filename=$(basename "$yaml" .yaml)

	yq -o=json "$yaml" | jq -r '
    "#!/bin/sh\n\n# Scheme: \(.name) (\(.variant))\n# Author: \(.author)\n\n" +
    (.palette | to_entries | map(select(.key | test("^base0[0-9A-Fa-f]$")) | "export \(.key)=\"\(.value)\"") | join("\n"))
  ' >"$TARGET_DIR/$filename.sh"
done

rm -rf "$TMP_CLONE"

echo "$(find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -printf 'x' | wc -c) palettes have been synced to '$TARGET_DIR'"
