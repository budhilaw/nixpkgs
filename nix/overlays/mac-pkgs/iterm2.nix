{
  lib,
  stdenv,
  fetchurl,
  undmg,
  unzip,
}:

let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "iterm2";

  version =
    rec {
      aarch64-darwin = "3_5_4";
      x86_64-darwin = aarch64-darwin;
    }
    .${system} or throwSystem;

  sha256 =
    rec {
      aarch64-darwin = "sha256-rPuPk1UCd8IxxXKkiM0CkOdLzlODVKX1UVqInqS0S9U=";
      x86_64-darwin = aarch64-darwin;
    }
    .${system} or throwSystem;

  srcs =
    let
      base = "https://iterm2.com/downloads/stable";
    in
    rec {
      aarch64-darwin = {
        url = "${base}/iTerm2-${version}.zip";
        sha256 = sha256;
      };
      x86_64-darwin = aarch64-darwin;
    };

  src = fetchurl (srcs.${system} or throwSystem);

  meta = with lib; {
    description = "Terminal emulator as alternative to Apple's Terminal app";
    homepage = "https://iterm2.com/";
    platforms = [
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };

  appname = "Iterm";

  darwin = stdenv.mkDerivation {
    inherit
      pname
      version
      src
      meta
      ;

    nativeBuildInputs = [ undmg ];
    buildInputs = [ unzip ];
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
      "unpackPhase"
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