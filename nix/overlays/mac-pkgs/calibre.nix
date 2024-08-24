{
  lib,
  stdenv,
  fetchurl,
  undmg,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "calibre";

  version =
    rec {
      aarch64-darwin = "7.17.0";
      x86_64-darwin = aarch64-darwin;
    }
    .${system} or throwSystem;

  sha256 =
    rec {
      aarch64-darwin = "sha256-y/rUjRCEenWP24sw8YcI+2R9FHM7I2yX10hIV3qnDwU=";
      x86_64-darwin = aarch64-darwin;
    }
    .${system} or throwSystem;

  srcs =
    let
      base = "https://download.calibre-ebook.com";
    in
    rec {
      aarch64-darwin = {
        url = "${base}/${version}/calibre-${version}.dmg";
        sha256 = sha256;
      };
      x86_64-darwin = aarch64-darwin;
    };

  src = fetchurl (srcs.${system} or throwSystem);

  meta = with lib; {
    description = "calibre";
    homepage = "https://calibre-ebook.com/";
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [ undmg ];

    sourceRoot = "Calibre.app";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications/Calibre.app
      cp -R . $out/Applications/Calibre.app
      runHook postInstall
    '';
  };
in
darwin