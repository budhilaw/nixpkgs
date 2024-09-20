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

    nativeBuildInputs = [ undmg ];
    unpackCmd = ''
      echo "File to unpack: $curSrc"
      if ! [[ "$curSrc" =~ \.dmg$ ]]; then return 1; fi
      mnt=$(mktemp -d -t ci-XXXXXXXXXX)

      function finish {
        echo "Detaching $mnt"
        /usr/bin/hdiutil detach $mnt -force
        rm -rf $mnt
      }
      trap finish EXIT

      echo "Attaching $mnt"
      /usr/bin/hdiutil attach -nobrowse -readonly $src -mountpoint $mnt

      echo "What's in the mount dir"?
      ls -la $mnt/

      echo "Copying contents"
      shopt -s extglob
      DEST="$PWD"
      (cd "$mnt"; cp -a !(Applications) "$DEST/")
    '';
    
    phases = [
      "installPhase"
    ];

    sourceRoot = "${appname}.app";

    installPhase = ''
      mkdir -p "$out/Applications/${appname}.app"
      cp -a ./. "$out/Applications/${appname}.app/"
    '';
  };
in
darwin
