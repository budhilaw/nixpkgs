{ inputs, ... }:

{
  imports = [
    ./mac-pkgs
  ];

  flake.overlays.default = final: prev: {

    nixfmt = prev.nixfmt-rfc-style;

    iamb = inputs.iamb.packages.${prev.stdenv.hostPlatform.system}.default;

    fishPlugins = prev.fishPlugins // {
      nix-env = {
        name = "nix-env";
        src = inputs.nix-env;
      };
    };
  };
}