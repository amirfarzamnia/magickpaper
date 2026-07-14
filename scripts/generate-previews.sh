#!/usr/bin/env bash

set -euo pipefail

GENERATOR="$(pwd)/magickpaper.sh"
STYLE_DIR="$(pwd)/styles"
OUTPUT_DIR="$(pwd)/previews"

WIDTH=960
HEIGHT=540

mkdir -p "$OUTPUT_DIR"

echo "Generating previews..."

for style_file in "$STYLE_DIR"/*.sh; do
	[[ -e $style_file ]] || continue

	style="$(basename "$style_file" .sh)"
	output="$OUTPUT_DIR/$style.png"

	echo "Generating $output"

	bash "$GENERATOR" -s "$style" -w "$WIDTH" -h "$HEIGHT" -o "$output"
done

echo "Previews are available in $OUTPUT_DIR"
