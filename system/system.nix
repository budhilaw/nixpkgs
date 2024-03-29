{ pkgs, lib, ... }:
{
  # https://github.com/nix-community/home-manager/issues/423
  programs.nix-index.enable = true;
  # Nix configuration ------------------------------------------------------------------------------

  # Bootstrap
  nix = {
    configureBuildUsers = true;
    settings = {
      auto-optimise-store = true;

      trusted-users = [
        "@admin"
        "budhilaw"
      ];

      substituters = [
        "https://nix-community.cachix.org"
        "https://budhilaw.cachix.org/"
        "https://devenv.cachix.org"
      ];


      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "budhilaw.cachix.org-1:Fbyz4CIpkeY0n6XkK3v2lznxqAvA+vGBJGHBahaI53A="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };


    # enable garbage-collection on weekly and delete-older-than 30 day
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    # this is configuration for /etc/nix/nix.conf
    # so it will generated /etc/nix/nix.conf
    extraOptions = ''
     experimental-features = nix-command flakes
     keep-outputs = true
     keep-derivations = true
    '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
     extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  system = {
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;
  };
}