_final: prev:

let
  inherit (prev.lib) attrsets;
  callPackage = prev.newScope { };
  packages = [
    "pritunl"
    # "googlechrome" # see system/darwin/homebrew.nix
  ];
in

attrsets.genAttrs packages (name: callPackage ./${name}.nix { })