{ config, pkgs, lib,... }:

{
   # Setup go
   programs.go.enable = true;
   programs.go.package = with pkgs;go.overrideAttrs (oldAttrs: rec {
    version = "1.18.5";
    src = fetchurl {
      url = "https://dl.google.com/go/go${version}.src.tar.gz";
      sha256 = "sha256-mSDTMGoaxTbN0seW1ss8VLxVnCJvw8w5wy8eC9f1DSo=";
    };
  });
}