{
  description = "A tool for generating procedural wallpapers with ImageMagick";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      systems = lib.systems.flakeExposed;

      forAllSystems =
        f:
        lib.genAttrs systems (
          system:
          f {
            pkgs = nixpkgs.legacyPackages.${system};
            inherit system;
          }
        );
    in
    {
      packages = forAllSystems (
        { pkgs, ... }:
        let
          magickpaper = pkgs.stdenv.mkDerivation {
            pname = "magickpaper";
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs = [
              pkgs.makeWrapper
            ];

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              runHook preInstall

              install -Dm755 magickpaper.sh \
                "$out/share/magickpaper/magickpaper.sh"

              cp -r styles palettes "$out/share/magickpaper/"

              makeWrapper \
                "$out/share/magickpaper/magickpaper.sh" \
                "$out/bin/magickpaper" \
                --chdir "$out/share/magickpaper" \
                --set PATH "${
                  lib.makeBinPath [
                    pkgs.bash
                    pkgs.coreutils
                    pkgs.imagemagick
                  ]
                }"

              runHook postInstall
            '';

            doInstallCheck = true;

            installCheckPhase = ''
              runHook preInstallCheck

              output="$TMPDIR/magickpaper-test.png"

              "$out/bin/magickpaper" \
                -s vertical-stripes \
                -w 32 \
                -h 18 \
                -o "$output"

              test -s "$output"
              ${pkgs.imagemagick}/bin/magick identify "$output"

              runHook postInstallCheck
            '';

            meta = {
              mainProgram = "magickpaper";
              description = "A tool for generating procedural wallpapers with ImageMagick";
              homepage = "https://github.com/amirfarzamnia/magickpaper";
              license = lib.licenses.mit;
              platforms = lib.platforms.unix;
            };
          };
        in
        {
          inherit magickpaper;
          default = magickpaper;
        }
      );

      apps = forAllSystems (
        { pkgs, ... }:
        let
          package = pkgs.callPackage (
            {
              stdenv,
              makeWrapper,
              bash,
              coreutils,
              imagemagick,
            }:
            stdenv.mkDerivation {
              pname = "magickpaper";
              version = "0.1.0";
              src = ./.;

              nativeBuildInputs = [ makeWrapper ];

              dontConfigure = true;
              dontBuild = true;

              installPhase = ''
                install -Dm755 magickpaper.sh \
                  "$out/share/magickpaper/magickpaper.sh"

                cp -r styles palettes "$out/share/magickpaper/"

                makeWrapper \
                  "$out/share/magickpaper/magickpaper.sh" \
                  "$out/bin/magickpaper" \
                  --chdir "$out/share/magickpaper" \
                  --set PATH "${
                    lib.makeBinPath [
                      bash
                      coreutils
                      imagemagick
                    ]
                  }"
              '';
            }
          ) { };
        in
        {
          default = {
            type = "app";
            program = "${package}/bin/magickpaper";
          };

          magickpaper = {
            type = "app";
            program = "${package}/bin/magickpaper";
          };
        }
      );
    };
}
