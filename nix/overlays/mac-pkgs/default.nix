{ ... }:
{
  flake.overlays.macos =
    final: prev:
    let
      inherit (prev.lib) attrsets;
      callPackage = prev.newScope { };
      packages = [
        "obs-studio"
        "orbstack"
        "telegram"
        "shottr"
      ];
    in

    attrsets.genAttrs packages (name: callPackage ./${name}.nix { });
}