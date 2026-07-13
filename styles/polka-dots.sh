#!/bin/bash

TILE_SZ=$((120 * SCALE))
RAD_1=$((TILE_SZ / 4))

magick -size "${TILE_SZ}x${TILE_SZ}" xc:"${COLORS[0]}" \
	-fill "${COLORS[4]}" -draw "circle $((TILE_SZ / 2)),$((TILE_SZ / 2)) $((TILE_SZ / 2)),$((TILE_SZ / 2 + RAD_1))" \
	-fill "${COLORS[5]}" -draw "circle 0,0 0,${RAD_1}" \
	-fill "${COLORS[5]}" -draw "circle ${TILE_SZ},0 ${TILE_SZ},${RAD_1}" \
	-fill "${COLORS[5]}" -draw "circle 0,${TILE_SZ} 0,$((TILE_SZ - RAD_1))" \
	-fill "${COLORS[5]}" -draw "circle ${TILE_SZ},${TILE_SZ} ${TILE_SZ},$((TILE_SZ - RAD_1))" \
	-write mpr:dottile +delete \
	-size "${WIDTH}x${HEIGHT}" tile:mpr:dottile \
	-resize "${TARGET_WIDTH}x${TARGET_HEIGHT}!" "$OUTPUT_FILE"
