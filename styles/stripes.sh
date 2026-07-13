#!/bin/bash

magick "$(get_palette_expr "+append")" \
	-filter point -resize "${WIDTH}x${HEIGHT}!" \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
