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

IM_VERSION="$(magick -version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
IM_MAJOR="${IM_VERSION%%.*}"

if [[ -z $IM_MAJOR || $IM_MAJOR -lt 7 ]]; then
  error_exit "ImageMagick 7+ is required (found version: ${IM_VERSION:-unknown})."
fi

# ---------------------------------------------------------------------
# DEFAULT PARAMETERS
# ---------------------------------------------------------------------
export STYLE="vertical-stripes"
export TARGET_WIDTH=3840
export TARGET_HEIGHT=2160
export OUTPUT_FILE="wallpaper.png"
export PALETTE="catppuccin-mocha"
export CUSTOM_COLORS=""
export SCALE=2

# ---------------------------------------------------------------------
# ARGUMENT PARSING
# ---------------------------------------------------------------------
while getopts "s:w:h:o:c:p:" opt; do
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
# DIMENSION VALIDATION
# ---------------------------------------------------------------------
for dim_name in TARGET_WIDTH TARGET_HEIGHT; do
  dim_value="${!dim_name}"

  if [[ ! $dim_value =~ ^[1-9][0-9]*$ ]]; then
    error_exit "${dim_name} must be a positive integer (got: '${dim_value}')."
  fi
done

# ---------------------------------------------------------------------
# OUTPUT PATH VALIDATION
# ---------------------------------------------------------------------
OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"

if [[ ! -d $OUTPUT_DIR ]]; then
  error_exit "Output directory '${OUTPUT_DIR}' does not exist."
fi

if [[ ! -w $OUTPUT_DIR ]]; then
  error_exit "Output directory '${OUTPUT_DIR}' is not writable."
fi

# ---------------------------------------------------------------------
# PALETTE RESOLUTION
# ---------------------------------------------------------------------
export COLORS=()
HEX_PATTERN='^#[0-9a-fA-F]{6}$'

if [[ -n $CUSTOM_COLORS ]]; then
  IFS=' ' read -r -a COLORS <<<"$CUSTOM_COLORS"

  for color in "${COLORS[@]}"; do
    if [[ ! $color =~ $HEX_PATTERN ]]; then
      error_exit "Invalid custom color '${color}'. Expected format: #RRGGBB."
    fi
  done
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

  for i in "${!COLORS[@]}"; do
    if [[ ! ${COLORS[$i]} =~ $HEX_PATTERN ]]; then
      error_exit "Palette '${PALETTE}' has a missing or malformed color (index ${i}: '${COLORS[$i]}')."
    fi
  done
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
STYLE_FILE="${SCRIPT_DIR}/styles/${STYLE}.sh"

if [[ ! -f $STYLE_FILE ]]; then
  error_exit "Unknown style: '$STYLE'"
fi

# Source the individual style file to inherit local scope and execute layout
# shellcheck disable=SC1090
source "$STYLE_FILE"
