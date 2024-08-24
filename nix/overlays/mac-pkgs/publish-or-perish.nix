{
  lib,
  stdenv,
  fetchurl,
  undmg,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "publish-or-perish";

  version =
    rec {
      aarch64-darwin = "8.14.4639.8980";
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
      base = "https://harzing.com/download";
    in
    rec {
      aarch64-darwin = {
        url = "${base}/PoP${version}Mac.dmg";
        sha256 = sha256;
      };
      x86_64-darwin = aarch64-darwin;
    };

  src = fetchurl (srcs.${system} or throwSystem);

  meta = with lib; {
    description = "Harzing Publish or Perish";
    homepage = "https://harzing.com/resources/publish-or-perish";
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

    sourceRoot = "Publish or Perish.app";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications/Publish or Perish.app
      cp -R . $out/Applications/Publish or Perish.app
      runHook postInstall
    '';
  };
in
darwin