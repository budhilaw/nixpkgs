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
        "jetbrains-toolbox"
        "iterm2"
      ];
    in

    attrsets.genAttrs packages (name: callPackage ./${name}.nix { });
}
