#!/usr/bin/env bash

# Strict error handling
set -eo pipefail

# Get absolute path to the directory containing this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global tracking for cleanup traps
export TMP_DRAW=""

# ---------------------------------------------------------------------
# CLEANUP & ERROR HANDLING
# ---------------------------------------------------------------------
cleanup() {
	if [[ -n ${TMP_DRAW} && -f ${TMP_DRAW} ]]; then
		rm -f "$TMP_DRAW"
	fi
}
trap cleanup EXIT INT TERM

error_exit() {
	echo "Error: $1" >&2
	exit 1
}

# ---------------------------------------------------------------------
# DEPENDENCY CHECK
# ---------------------------------------------------------------------
if ! command -v magick &>/dev/null; then
	error_exit "ImageMagick (magick) is required but not installed."
fi

# ---------------------------------------------------------------------
# DEFAULT PARAMETERS
# ---------------------------------------------------------------------
export STYLE="stripes"
export TARGET_WIDTH=3840
export TARGET_HEIGHT=2160
export OUTPUT_FILE="wallpaper.png"
export PALETTE="catppuccin-mocha"
export CUSTOM_COLORS=""
export SCALE=2

# ---------------------------------------------------------------------
# ARGUMENT PARSING
# ---------------------------------------------------------------------
while getopts "s:w:h:o:c:p" opt; do
	case "$opt" in
	s) STYLE="$OPTARG" ;;
	w) TARGET_WIDTH="$OPTARG" ;;
	h) TARGET_HEIGHT="$OPTARG" ;;
	o) OUTPUT_FILE="$OPTARG" ;;
	c) CUSTOM_COLORS="$OPTARG" ;;
	p) PALETTE="$OPTARG" ;;
	*)
		exit 1
		;;
	esac
done

# ---------------------------------------------------------------------
# PALETTE RESOLUTION
# ---------------------------------------------------------------------
export COLORS=()

if [[ -n $CUSTOM_COLORS ]]; then
	IFS=' ' read -r -a COLORS <<<"$CUSTOM_COLORS"
else
	RESOLVED_PALETTE=""

	if [[ -f "${SCRIPT_DIR}/palettes/${PALETTE}.sh" ]]; then
		RESOLVED_PALETTE="${SCRIPT_DIR}/palettes/${PALETTE}.sh"
	elif [[ -f "${SCRIPT_DIR}/palettes/${PALETTE}" ]]; then
		RESOLVED_PALETTE="${SCRIPT_DIR}/palettes/${PALETTE}"
	else
		error_exit "Palette preset '${PALETTE}' not found in '${SCRIPT_DIR}/palettes/'."
	fi

	# shellcheck disable=SC1090
	source "$RESOLVED_PALETTE"

	# shellcheck disable=SC2154
	COLORS=(
		"${base00}" "${base01}" "${base02}" "${base03}"
		"${base04}" "${base05}" "${base06}" "${base07}"
		"${base08}" "${base09}" "${base0A}" "${base0B}"
		"${base0C}" "${base0D}" "${base0E}" "${base0F}"
	)
fi

if [[ ${#COLORS[@]} -eq 0 ]]; then
	error_exit "No colors loaded. Check your custom hex formatting or palette file syntax."
fi

export WIDTH=$((TARGET_WIDTH * SCALE))
export HEIGHT=$((TARGET_HEIGHT * SCALE))

# ---------------------------------------------------------------------
# IMAGEMAGICK EXPRESSION HELPERS
# ---------------------------------------------------------------------
get_palette_expr() {
	local direction="$1"
	local cmd=""
	for color in "${COLORS[@]}"; do
		cmd+=" -size 1x1 xc:${color}"
	done
	cmd+=" ${direction}"
	echo "$cmd"
}

get_clut_expr() {
	local cmd="( -size 1x1"
	for color in "${COLORS[@]}"; do
		cmd+=" xc:${color}"
	done
	cmd+=" +append )"
	echo "$cmd"
}

# ---------------------------------------------------------------------
# WALLPAPER GENERATION ENGINE (MODULAR)
# ---------------------------------------------------------------------
# Convert spaces to underscores for file parsing (e.g., "diagonal stripes" -> "diagonal_stripes.sh")
STYLE_SLUG="${STYLE// /_}"
STYLE_FILE="${SCRIPT_DIR}/styles/${STYLE_SLUG}.sh"

if [[ ! -f $STYLE_FILE ]]; then
	error_exit "Unknown style pattern or missing module file: '$STYLE' (Expected: styles/${STYLE_SLUG}.sh)"
fi

# Source the individual style file to inherit local scope and execute layout
# shellcheck disable=SC1090
source "$STYLE_FILE"
