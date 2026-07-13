{ pkgs, ... }:
{
  languages = {
    nix.enable = true;
    shell.enable = true;
  };

  packages = with pkgs; [
    yq-go
    jq
    imagemagick
  ];

  scripts = {
    sync-palettes.exec = ''
      #!/usr/bin/env bash

      set -euo pipefail

      TARGET_DIR="./palettes"
      TMP_CLONE=$(mktemp -d)

      echo "Fetching latest tinted-theming base16 schemes..."
      git clone --depth 1 https://github.com/tinted-theming/schemes.git "$TMP_CLONE" &>/dev/null

      mkdir -p "$TARGET_DIR"
      echo "Processing and formatting palettes into '$TARGET_DIR'..."

      for yaml in "$TMP_CLONE/base16"/*.yaml; do
          [ -e "$yaml" ] || continue
          filename=$(basename "$yaml" .yaml)

          yq -o=json "$yaml" | jq -r '
            "#!/bin/sh\n\n# Scheme: \(.name) (\(.variant))\n# Author: \(.author)\n\n" +
            (.palette | to_entries | map(select(.key | test("^base0[0-9A-Fa-f]$")) | "export \(.key)=\"\(.value)\"") | join("\n"))
          ' > "$TARGET_DIR/$filename.sh"
      done

      rm -rf "$TMP_CLONE"
      echo "$(ls -1 "$TARGET_DIR" | wc -l) palettes have been synced to '$TARGET_DIR'"
    '';

    generate-previews.exec = ''
      #!/usr/bin/env bash

      set -euo pipefail

      GENERATOR="$(pwd)/magickpaper.sh"
      STYLE_DIR="$(pwd)/styles"
      OUTPUT_DIR="$(pwd)/previews"

      WIDTH=960
      HEIGHT=540

      mkdir -p "$OUTPUT_DIR"

      echo "Generating previews..."

      for style_file in "$STYLE_DIR"/*.sh; do
        [[ -e "$style_file" ]] || continue

        style="$(basename "$style_file" .sh)"
        output="$OUTPUT_DIR/$style.png"

        echo "Generating $output"

        bash "$GENERATOR" -s "$style" -w "$WIDTH" -h "$HEIGHT" -o "$output"
      done

      echo "Previews are available in $OUTPUT_DIR"
    '';
  };

  git-hooks.hooks = {
    # Git / commit hygiene
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-merge-conflicts.enable = true;
    commitizen.enable = true;
    end-of-file-fixer.enable = true;
    mixed-line-endings.enable = true;
    trim-trailing-whitespace.enable = true;

    # Markdown / documentation
    markdownlint.enable = true;

    # Nix
    deadnix.enable = true;
    nixfmt.enable = true;
    statix.enable = true;

    # Shell
    shellcheck.enable = true;
    shfmt.enable = true;

    # Workflows / misc
    actionlint.enable = true;
    typos.enable = true;
  };
}
