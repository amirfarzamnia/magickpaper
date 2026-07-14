{
  description = "A tool for generating wallpapers with ImageMagick";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, utils }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      rec {
        packages.magickpaper = pkgs.stdenv.mkDerivation {
          pname = "magickpaper";
          version = "0.1.0";

          src = ./.;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          # We need imagemagick for 'magick', and coreutils/gnused/bash for script execution
          buildInputs = [
            pkgs.bash
            pkgs.imagemagick
            pkgs.coreutils
            pkgs.gnused
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin $out/share/magickpaper

            # Copy styles, palettes, and the core script to a shared directory
            cp -r styles palettes magickpaper.sh $out/share/magickpaper/

            # Write a wrapper to ensure magickpaper always runs with its styles/palettes directory local to it,
            # and that 'magick' and other standard utilities are available in its PATH.
            makeWrapper $out/share/magickpaper/magickpaper.sh $out/bin/magickpaper \
              --prefix PATH : ${
                pkgs.lib.makeBinPath [
                  pkgs.imagemagick
                  pkgs.coreutils
                  pkgs.gnused
                ]
              } \
              --chdir $out/share/magickpaper

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "A tool for generating wallpapers with ImageMagick";
            homepage = "https://github.com/amirfarzamnia/magickpaper";
            license = licenses.mit;
            platforms = platforms.all;
          };
        };

        packages.default = packages.magickpaper;

        # Allows quick testing with `nix run github:username/magickpaper -- -s vertical-waves -o test.png`
        apps.default = {
          type = "app";
          program = "${packages.magickpaper}/bin/magickpaper";
        };
      }
    );
}
