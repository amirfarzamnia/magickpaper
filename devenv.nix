{ pkgs, ... }:
{
  # ============================================================================
  # Metadata
  # ============================================================================

  name = "magickpaper";

  # ============================================================================
  # Language & Environment Setup
  # ============================================================================

  languages = {
    nix.enable = true;
    shell.enable = true;
  };

  # ============================================================================
  # Code Formatting (treefmt)
  # ============================================================================

  treefmt = {
    enable = true;
    config.programs = {
      nixfmt.enable = true;
      taplo.enable = true;
      yamlfmt.enable = true;
      mdformat.enable = true;
      shfmt.enable = true;
    };
  };

  # ============================================================================
  # Development Packages
  # ============================================================================

  packages = with pkgs; [
    yq-go
    jq
    imagemagick
  ];

  # ============================================================================
  # Development Scripts
  # ============================================================================

  scripts = {
    generate-previews.exec = builtins.readFile ./scripts/generate-previews.sh;
    sync-palettes.exec = builtins.readFile ./scripts/sync-palettes.sh;
  };

  # ============================================================================
  # Git Hooks
  # ============================================================================

  git-hooks.hooks = {
    # CI/CD Workflows & Repository Hygiene
    actionlint.enable = true;
    commitizen.enable = true;
    treefmt.enable = true;
    typos.enable = true;

    # Code Safety & File Formatting
    check-added-large-files.enable = true;
    check-case-conflicts.enable = true;
    check-merge-conflicts.enable = true;
    end-of-file-fixer.enable = true;
    mixed-line-endings.enable = true;
    trim-trailing-whitespace.enable = true;

    # Documentation & Markup
    markdownlint = {
      enable = true;
      settings.configuration.MD013 = false;
    };

    # Nix
    deadnix.enable = true;
    statix.enable = true;

    # Shell
    shellcheck.enable = true;
  };
}
