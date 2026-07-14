#!/bin/bash

CELL_SIZE=$((120 * SCALE))
PERTURB_MAX=$((CELL_SIZE * 30 / 100))
LEAD_LINE_WIDTH=$((4 * SCALE))
PADDING=$((CELL_SIZE * 2))

declare -A POINTS_X POINTS_Y

NUM_X=$(((WIDTH + PADDING * 2) / CELL_SIZE + 1))
NUM_Y=$(((HEIGHT + PADDING * 2) / CELL_SIZE + 1))

for ((i = -1; i <= NUM_X + 1; i++)); do
	for ((j = -1; j <= NUM_Y + 1; j++)); do
		BASE_X=$(((i * CELL_SIZE) - PADDING))
		BASE_Y=$(((j * CELL_SIZE) - PADDING))

		RANDOM_X=$((RANDOM % (PERTURB_MAX * 2 + 1) - PERTURB_MAX))
		RANDOM_Y=$((RANDOM % (PERTURB_MAX * 2 + 1) - PERTURB_MAX))

		KEY="${i}_${j}"
		POINTS_X[$KEY]=$((BASE_X + RANDOM_X))
		POINTS_Y[$KEY]=$((BASE_Y + RANDOM_Y))
	done
done

TMP_DRAW=$(mktemp)

for ((i = -1; i <= NUM_X; i++)); do
	for ((j = -1; j <= NUM_Y; j++)); do
		C_IDX=$((RANDOM % (${#COLORS[@]} - 1) + 1))

		K1="${i}_${j}"
		X1=${POINTS_X[$K1]}
		Y1=${POINTS_Y[$K1]}

		K2="$((i + 1))_${j}"
		X2=${POINTS_X[$K2]}
		Y2=${POINTS_Y[$K2]}

		K3="$((i + 1))_$((j + 1))"
		X3=${POINTS_X[$K3]}
		Y3=${POINTS_Y[$K3]}

		K4="${i}_$((j + 1))"
		X4=${POINTS_X[$K4]}
		Y4=${POINTS_Y[$K4]}

		POLYGON_POINTS="${X1},${Y1} ${X2},${Y2} ${X3},${Y3} ${X4},${Y4}"

		echo "stroke ${COLORS[0]} stroke-width ${LEAD_LINE_WIDTH} fill ${COLORS[$C_IDX]} polygon ${POLYGON_POINTS}" >>"$TMP_DRAW"
	done
done

magick -size "${WIDTH}x${HEIGHT}" xc:"${COLORS[0]}" -draw "@$TMP_DRAW" \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
