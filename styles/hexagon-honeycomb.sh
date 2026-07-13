#!/bin/bash

SIZE=$((50 * SCALE))
R=$SIZE
R_HALF=$((R / 2))
H_SPACING=$((R * 3 / 2))
R_866=$((R * 866 / 1000))
V_SPACING=$((R_866 * 2))

TMP_DRAW=$(mktemp)
COL=0

for ((x = -SIZE * 2; x < WIDTH + SIZE * 2; x += H_SPACING)); do
	ROW_OFFSET=0
	[[ $((COL % 2)) -eq 1 ]] && ROW_OFFSET=$R_866

	for ((y = -V_SPACING * 2; y < HEIGHT + V_SPACING * 2; y += V_SPACING)); do
		Y_POS=$((y + ROW_OFFSET))
		C_IDX=$((RANDOM % ${#COLORS[@]}))

		echo "stroke ${COLORS[0]} stroke-width $((2 * SCALE)) fill ${COLORS[$C_IDX]} polygon $((x + R)),${Y_POS} $((x + R_HALF)),$((Y_POS + R_866)) $((x - R_HALF)),$((Y_POS + R_866)) $((x - R)),${Y_POS} $((x - R_HALF)),$((Y_POS - R_866)) $((x + R_HALF)),$((Y_POS - R_866))" >>"$TMP_DRAW"
	done
	COL=$((COL + 1))
done

magick -size "${WIDTH}x${HEIGHT}" xc:"${COLORS[0]}" -draw "@$TMP_DRAW" \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
