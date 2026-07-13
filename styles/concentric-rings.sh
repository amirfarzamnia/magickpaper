#!/bin/bash

CX=$((WIDTH / 2))
CY=$((HEIGHT / 2))
MAX_R=$(((WIDTH + HEIGHT) / 2))
DRAW_CMD=""
NUM_COLORS=${#COLORS[@]}

for ((i = 0; i < NUM_COLORS; i++)); do
	R=$((MAX_R * (NUM_COLORS - i) / NUM_COLORS))
	DRAW_CMD+="fill ${COLORS[$i]} circle ${CX},${CY} ${CX},$((CY + R)) "
done

magick -size "${WIDTH}x${HEIGHT}" xc:"${COLORS[0]}" -draw "${DRAW_CMD}" \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
