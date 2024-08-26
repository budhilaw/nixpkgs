{
  lib,
  stdenv,
  fetchurl,
  undmg,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "jetbrains-toolbox";

  version =
    rec {
      aarch64-darwin = "2.4.2,2.4.2.32922";
      x86_64-darwin = aarch64-darwin;
    }
    .${system} or throwSystem;

  sha256 =
    rec {
      aarch64-darwin = "sha256-8KPYzIZ1jiL5Z5DFnMRJ0a/W6C554GhNllYY5xz5Lkw=";
      x86_64-darwin = aarch64-darwin;
    }
    .${system} or throwSystem;

  srcs =
    let
      base = "https://download.jetbrains.com/toolbox/";
    in
    rec {
      aarch64-darwin = {
        url = "${base}/jetbrains-toolbox-${version}-arm64.dmg";
        sha256 = sha256;
      };
      x86_64-darwin = aarch64-darwin;
    };

  src = fetchurl (srcs.${system} or throwSystem);

  meta = with lib; {
    description = "JetBrains tools manager";
    homepage = "https://jetbrains.com/";
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

    sourceRoot = "Jetbrains Toolbox.app";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications/Jetbrains Toolbox.app
      cp -R . $out/Applications/Jetbrains Toolbox.app
      runHook postInstall
    '';
  };
in
darwin