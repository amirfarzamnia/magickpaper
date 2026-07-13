#!/bin/bash

AMPLITUDE=$((180 * SCALE))
WAVELENGTH=$WIDTH
PAD_HEIGHT=$((HEIGHT + AMPLITUDE * 2))

magick "$(get_palette_expr "-append")" \
	-filter point -resize "${WIDTH}x${PAD_HEIGHT}!" \
	-wave "${AMPLITUDE}x${WAVELENGTH}" \
	-gravity center -crop "${WIDTH}x${HEIGHT}+0+0" +repage \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
