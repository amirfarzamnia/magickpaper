#!/bin/bash

# shellcheck disable=SC2046
magick $(get_palette_expr "+append") \
	-filter point -resize "${WIDTH}x${HEIGHT}!" \
	-distort Polar "0,0 $((WIDTH / 2)),$((HEIGHT / 2)) 0,360" \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
