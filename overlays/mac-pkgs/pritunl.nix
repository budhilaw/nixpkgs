{ lib
, stdenv
, fetchurl
, undmg
, unzip
,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "pritunl";

  version = rec {
    aarch64-darwin = "1.3.3600.11";
  }.${system} or throwSystem;

  sha256 = rec {
    aarch64-darwin = "fe1b7e81fefcb5d478d9a89404c474fed4630e5f61182bca2811810700f701bb";
  }.${system} or throwSystem;

  srcs =
    let
      base = "https://github.com/pritunl/pritunl-client-electron/releases/download/";
    in
    rec {
      aarch64-darwin = {
        inherit sha256;
        url = "${base}/Pritunl.arm64.pkg.zip";
      };
    };

  src = fetchurl (srcs.${system} or throwSystem);

  meta = with lib; {
    description = "Pritunl Client";
    homepage = "https://client.pritunl.com/";
    platforms = [ "aarch64-darwin" ];
  };

  appname = "Pritunl";

  darwin = stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [ undmg ];
    buildInputs = [ unzip ];

    sourceRoot = "${appname}.app";

    installPhase = ''
      mkdir -p "$out/Applications/${appname}.app"
      cp -a ./. "$out/Applications/${appname}.app/"
    '';
  };
in
darwin