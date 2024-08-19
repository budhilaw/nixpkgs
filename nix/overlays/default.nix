{ inputs, ... }:

{
  imports = [

  ];

  flake.overlays.default = final: prev: {
    nixfmt = prev.nixfmt-rfc-style;

    fishPlugins = prev.fishPlugins // {
      nix-env = {
        name = "nix-env";
        src = inputs.nix-env;
      };
    };
  };
}
