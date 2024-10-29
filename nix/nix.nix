{
  lib,
  stdenv,
  inputs,
  ...
}:

let
  nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
in
{
  inherit nixPath;

  configureBuildUsers = true;

  registry = {
    system.flake = inputs.self;
    default.flake = inputs.nixpkgs;
    nixpkgs.flake = inputs.nixpkgs;
    nix.flake = inputs.nix;
    nix-darwin.flake = inputs.nix-darwin;
    home-manager.flake = inputs.home-manager;
    devenv.flake = inputs.devenv;
  };

  settings =
    {
      nix-path = nixPath;
      auto-optimise-store = true;
      accept-flake-config = true;
      builders-use-substitutes = false;
      download-attempts = 3;
      fallback = true;
      http-connections = 0;
      max-jobs = "auto";

      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "flakes"
        "nix-command"
      ];

      trusted-users = [
        "budhilaw"
        "root"
        "nixos"
      ];

      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://budhilaw.cachix.org/"
        "https://devenv.cachix.org"
      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "budhilaw.cachix.org-1:Fbyz4CIpkeY0n6XkK3v2lznxqAvA+vGBJGHBahaI53A="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    }
    // (lib.optionalAttrs (stdenv.isDarwin && stdenv.isAarch64) {
      extra-platforms = "x86_64-darwin aarch64-darwin";
    });

  # enable garbage-collection on weekly and delete-older-than 30 day
  gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # this is configuration for /etc/nix/nix.conf
  # so it will generated /etc/nix/nix.conf
  extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    auto-allocate-uids = false
  '';
}
