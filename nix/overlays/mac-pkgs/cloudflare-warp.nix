{
  lib,
  stdenv,
  fetchurl,
  undmg,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "cloudflare-warp";

  version =
    rec {
      aarch64-darwin = "5.5.5";
      x86_64-darwin = aarch64-darwin;
    }
    .${system} or throwSystem;

  sha256 =
    rec {
      aarch64-darwin = "sha256-KgfhxQn8PZX3/puQNitNhT/MBDOAih1oqqvxBAYUW+A=";
      x86_64-darwin = aarch64-darwin;
    }
    .${system} or throwSystem;

  srcs =
    let
      base = "https://1111-releases.cloudflareclient.com";
    in
    rec {
      aarch64-darwin = {
        url = "${base}/mac/Cloudflare_WARP_${version}.pkg";
        sha256 = sha256;
      };
      x86_64-darwin = aarch64-darwin;
    };

  src = fetchurl (srcs.${system} or throwSystem);

  meta = with lib; {
    description = "Cloudflare Warp";
    homepage = "https://cloudflare.com//";
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };

  appname = "Cloudflare Warp";

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [
      makeWrapper
      xar
      cpio
    ];

    unpackPhase = lib.optionalString stdenv.isDarwin ''
      xar -xf $src
      zcat < warp.pkg/Payload | cpio -i
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/Applications
      cp -R ./Applications/${appname}.app $out/Applications/
      runHook postInstall
    '';
  };
in
darwin
