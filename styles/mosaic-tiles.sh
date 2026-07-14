#!/bin/bash

TILE_SIZE=$((100 * SCALE))
STROKE_WIDTH=$((4 * SCALE))

TMP_DRAW=$(mktemp)

for ((x = 0; x < WIDTH; x += TILE_SIZE)); do
	for ((y = 0; y < HEIGHT; y += TILE_SIZE)); do
		C_IDX=$((RANDOM % (${#COLORS[@]} - 1) + 1))

		X2=$((x + TILE_SIZE))
		Y2=$((y + TILE_SIZE))

		echo "stroke ${COLORS[0]} stroke-width ${STROKE_WIDTH} fill ${COLORS[$C_IDX]} rectangle ${x},${y} ${X2},${Y2}" >>"$TMP_DRAW"
	done
done

magick -size "${WIDTH}x${HEIGHT}" xc:"${COLORS[0]}" -draw "@$TMP_DRAW" \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
