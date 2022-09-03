{ config, pkgs, lib,... }:

{
   # Setup go
   programs.go.enable = true;
   programs.go.package = with pkgs;go.overrideAttrs (oldAttrs: rec { 
    # write new attr 
    version = "1.18.5";
    src = fetchurl {
        url = "https://dl.google.com/go/go${version}.src.tar.gz";
        sha256 = "sha256-mSDTMGoaxTbN0seW1ss8VLxVnCJvw8w5wy8eC9f1DSo=";
    };
    buildInputs = [
        pkgs.darwin.apple_sdk.frameworks.Security
        pkgs.darwin.apple_sdk.frameworks.CoreFoundation
        pkgs.darwin.apple_sdk.frameworks.CoreServices
    ]
        ++ lib.optionals stdenv.isLinux [ stdenv.cc.libc.out ]
        ++ lib.optionals (stdenv.hostPlatform.libc == "glibc") [ stdenv.cc.libc.static ];
  });
}