#!/bin/bash

DRAW_CMD=""
for ((i = 1; i <= 80; i++)); do
	X=$((RANDOM % WIDTH))
	Y=$((RANDOM % HEIGHT))
	R=$(((RANDOM % 400 + 150) * SCALE))
	C_IDX=$((RANDOM % (${#COLORS[@]} - 1) + 1))
	OPACITY="0.$((RANDOM % 4 + 3))"
	DRAW_CMD+="fill ${COLORS[$C_IDX]} fill-opacity ${OPACITY} circle ${X},${Y} ${X},$((Y + R)) "
done

magick -size "${WIDTH}x${HEIGHT}" xc:"${COLORS[0]}" -draw "${DRAW_CMD}" \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
