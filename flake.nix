{
  description = "A tool for generating procedural wallpapers with ImageMagick";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, utils, ... }:
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

          buildInputs = [
            pkgs.bash
            pkgs.imagemagick
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin $out/share/magickpaper
            cp -r styles palettes magickpaper.sh $out/share/magickpaper/

            makeWrapper $out/share/magickpaper/magickpaper.sh $out/bin/magickpaper \
              --prefix PATH : ${
                pkgs.lib.makeBinPath [
                  pkgs.bash
                  pkgs.imagemagick
                ]
              } \
              --chdir $out/share/magickpaper

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            mainProgram = "magickpaper";
            description = "A tool for generating procedural wallpapers with ImageMagick";
            homepage = "https://github.com/amirfarzamnia/magickpaper";
            license = licenses.mit;
            platforms = platforms.all;
          };
        };

        packages.default = packages.magickpaper;

        # Allows quick testing with `nix run github:amirfarzamnia/magickpaper -- -s waves -o test.png`
        apps.default = {
          type = "app";
          program = "${packages.magickpaper}/bin/magickpaper";
        };
      }
    );
}
