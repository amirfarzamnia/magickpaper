#!/bin/bash

DIAG_W=$((WIDTH * 2))
# shellcheck disable=SC2046
magick $(get_palette_expr "+append") \
	-filter point -resize "${DIAG_W}x${DIAG_W}!" \
	-distort SRT -45 \
	-gravity center -crop "${WIDTH}x${HEIGHT}+0+0" +repage \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
