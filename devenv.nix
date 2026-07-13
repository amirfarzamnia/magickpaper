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

  # Custom script to manage and convert palettes automatically
  scripts.sync-palettes.exec = ''
    #!/usr/bin/env bash
    set -euo pipefail

    TARGET_DIR="./palettes"
    TMP_CLONE=$(mktemp -d)

    echo "Fetching latest tinted-theming base16 schemes..."
    git clone --depth 1 https://github.com/tinted-theming/schemes.git "$TMP_CLONE" &>/dev/null

    mkdir -p "$TARGET_DIR"
    echo "Processing and formatting palettes into '$TARGET_DIR'..."

    # Loop through the cloned YAML files
    for yaml in "$TMP_CLONE/base16"/*.yaml; do
        [ -e "$yaml" ] || continue
        filename=$(basename "$yaml" .yaml)

        # Parse the nested palette object and format into shell assignments
        # Note: We use $TARGET_DIR and $filename without braces so Nix ignores them
        yq -o=json "$yaml" | jq -r '
          "#!/bin/sh\n\n# Scheme: \(.name) (\(.variant))\n# Author: \(.author)\n\n" +
          (.palette | to_entries | map(select(.key | test("^base0[0-9A-Fa-f]$")) | "export \(.key)=\"\(.value)\"") | join("\n"))
        ' > "$TARGET_DIR/$filename.sh"
    done

    rm -rf "$TMP_CLONE"
    echo "Done! $(ls -1 "$TARGET_DIR" | wc -l) palettes are now available completely offline as .sh files."
  '';

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
