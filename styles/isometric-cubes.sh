#!/bin/bash

SIZE=$((60 * SCALE))
R=$SIZE
R_866=$((R * 866 / 1000))
R_HALF=$((R / 2))
V_SPACING=$((R * 3))

TMP_DRAW=$(mktemp)
NUM_COLS=$((WIDTH / R_866 + 2))

for ((col = -2; col < NUM_COLS; col++)); do
	X_POS=$((col * R_866))
	ROW_OFFSET=0
	[[ $((col % 2)) -ne 0 ]] && ROW_OFFSET=$((V_SPACING / 2))

	for ((y = -V_SPACING; y < HEIGHT + V_SPACING; y += V_SPACING)); do
		Y_POS=$((y + ROW_OFFSET))
		C_IDX=$((RANDOM % ${#COLORS[@]}))

		{
			# Top Face
			echo "stroke ${COLORS[0]} stroke-width ${SCALE} fill ${COLORS[$C_IDX]} fill-opacity 1.0 polygon ${X_POS},${Y_POS} $((X_POS + R_866)),$((Y_POS - R_HALF)) ${X_POS},$((Y_POS - R)) $((X_POS - R_866)),$((Y_POS - R_HALF))"

			# Left Face
			echo "stroke ${COLORS[0]} stroke-width ${SCALE} fill ${COLORS[$C_IDX]} fill-opacity 1.0 polygon ${X_POS},${Y_POS} $((X_POS - R_866)),$((Y_POS - R_HALF)) $((X_POS - R_866)),$((Y_POS + R_HALF)) ${X_POS},$((Y_POS + R))"
			echo "stroke none fill black fill-opacity 0.20 polygon ${X_POS},${Y_POS} $((X_POS - R_866)),$((Y_POS - R_HALF)) $((X_POS - R_866)),$((Y_POS + R_HALF)) ${X_POS},$((Y_POS + R))"

			# Right Face
			echo "stroke ${COLORS[0]} stroke-width ${SCALE} fill ${COLORS[$C_IDX]} fill-opacity 1.0 polygon ${X_POS},${Y_POS} ${X_POS},$((Y_POS + R)) $((X_POS + R_866)),$((Y_POS + R_HALF)) $((X_POS + R_866)),$((Y_POS - R_HALF))"
			echo "stroke none fill black fill-opacity 0.40 polygon ${X_POS},${Y_POS} ${X_POS},$((Y_POS + R)) $((X_POS + R_866)),$((Y_POS + R_HALF)) $((X_POS + R_866)),$((Y_POS - R_HALF))"
		} >>"$TMP_DRAW"
	done
done

magick -size "${WIDTH}x${HEIGHT}" xc:"${COLORS[0]}" -draw "@$TMP_DRAW" \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
