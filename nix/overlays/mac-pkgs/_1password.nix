{
  lib,
  stdenv,
  fetchurl,
  undmg,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "_1password";

  # see version history https://desktop.telegram.org/changelog
  version =
    rec {
      aarch64-darwin = "8.10.40";
      x86_64-darwin = aarch64-darwin;
    }
    .${system} or throwSystem;

  # sha256 =
  #   rec {
  #     aarch64-darwin = "sha256-g6Cm3bMq8nVPf2On94yNYmKdfnCyxaEsnVbsJYBaVZs";
  #     x86_64-darwin = aarch64-darwin;
  #   }
  #   .${system} or throwSystem;

  srcs =
    let
      base = "https://downloads.1password.com/mac";
    in
    rec {
      aarch64-darwin = {
        url = "${base}/1Password.pkg";
        # sha256 = sha256;
      };
      x86_64-darwin = aarch64-darwin;
    };

  src = fetchurl (srcs.${system} or throwSystem);

  meta = with lib; {
    description = "1Password";
    homepage = "https://1password.com/";
    # license = licenses.gpl3Only;
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

    sourceRoot = "1Password.app";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications/1Password.app
      cp -R . $out/Applications/1Password.app
      runHook postInstall
    '';
  };
in
darwin