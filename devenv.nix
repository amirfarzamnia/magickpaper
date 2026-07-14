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
    sync-palettes.exec = builtins.readFile ./scripts/sync-palettes.sh;
    generate-previews.exec = builtins.readFile ./scripts/generate-previews.sh;
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
