{
  description = "Budhilaw's Nix darwin system configs.";

  inputs = {
    # Package sets
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-22.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-stable.url = "github:NixOS/nixpkgs/nixos-22.05";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.utils.follows = "flake-utils";

    # Other sources
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";
    prefmanager.url = "github:malob/prefmanager";
    prefmanager.inputs.nixpkgs.follows = "nixpkgs-unstable";
    prefmanager.inputs.flake-compat.follows = "flake-compat";
    prefmanager.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, darwin, nixpkgs, home-manager, flake-utils , ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable optionalAttrs singleton;

      # Configuration for `nixpkgs`
      nixpkgsConfig = {
        config = { allowUnfree = true; };
        overlays = attrValues self.overlays ++ singleton (
          # Sub in x86 version of packages that don't build on Apple Silicon yet
          final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            inherit (final.pkgs-x86)
              # yadm
              niv;
            
            # See https://github.com/LnL7/nix-darwin/issues/477
            nix = prev.nix.overrideAttrs (old: {
              patches =
                (old.patches or [])
                ++ [
                  ./patches/hush-nix-darwin.patch
                ];
            });
          })
        );
      };

      # Personal configuration shared between `nix-darwin` and plain `home-manager` configs.
      homeManagerStateVersion = "22.05";

      primaryUserInfo = {
        username = "budhilaw";
        fullName = "Ericsson Budhilaw";
        email = "ericsson@budhilaw.com";
        nixConfigDirectory = "/Users/budhilaw/.config/nixpkgs";
      };

      # Modules shared by most `nix-darwin` personal configurations.
      nixDarwinCommonModules = attrValues self.commonModules ++ attrValues self.darwinModules ++ [
        # `home-manager` module
        home-manager.darwinModules.home-manager
        (
          { config, lib, pkgs, ... }:
          let
            inherit (config.users) primaryUser;
          in
          {
            nixpkgs = nixpkgsConfig;
            # Hack to support legacy worklows that use `<nixpkgs>` etc.
            nix.nixPath = { nixpkgs = "${primaryUser.nixConfigDirectory}/nixpkgs.nix"; };
            # `home-manager` config
            users.users.${primaryUser.username} = {
              home = "/Users/${primaryUser.username}";
              shell = pkgs.fish;
            };
            home-manager.useGlobalPkgs = true;
            home-manager.users.${primaryUser.username} = {
              imports = attrValues self.homeManagerModules;
              home.stateVersion = homeManagerStateVersion;
              home.user-info = config.users.primaryUser;
            };
            # Add a registry entry for this flake
            nix.registry.my.flake = self;
          }
        )
      ];
    in
    {
      # System outputs ------------------------------------------------------------------------- {{{
      # 'mix-darwin' configs
      darwinConfigurations = rec {
        # Mininal configurations to bootstrap systems
        bootstrap-x86 = makeOverridable darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./darwin/bootstrap.nix { nixpkgs = nixpkgsConfig; } ];
        };
        bootstrap-arm = bootstrap-x86.override { system = "aarch64-darwin"; };

        # My Apple Silicon macOS laptop config
        Budhilaw = makeOverridable darwinSystem {
          system = "aarch64-darwin";
          modules = nixDarwinCommonModules ++ [
            {
              users.primaryUser = primaryUserInfo;
              networking.computerName = "Budhilaw 💻";
              networking.hostName = "Budhilaw-MBP";
              networking.knownNetworkServices = [
                "Wi-Fi"
                "USB 10/100/1000 LAN"
              ];
            }
          ];
        };

        # Config with small modifications needed/desired for CI with GitHub workflow
        githubCI = darwinSystem {
          system = "x86_64-darwin";
          modules = nixDarwinCommonModules ++ [
            ({ lib, ... }: {
              users.primaryUser = primaryUserInfo // {
                username = "runner";
                nixConfigDirectory = "/Users/runner/work/nixpkgs/nixpkgs";
              };
              homebrew.enable = lib.mkForce false;
            })
          ];
        };
      };

      # Overlays --------------------------------------------------------------- {{{

      overlays = import ./modules/overlays inputs nixpkgsConfig;

      # `home-manager` modules
      homeManagerModules = {
        budhilaw-packages = import ./home/packages.nix;
        budhilaw-shells = import ./home/shells.nix;
        budhilaw-git = import ./home/git.nix;
        budhilaw-starship = import ./home/starship.nix;
        budhilaw-starship-symbols = import ./home/starship-symbols.nix;
        budhilaw-golang = import ./home/go.nix;

        home-user-info = { lib, ... }: {
          options.home.user-info =
            (self.commonModules.users-primaryUser { inherit lib; }).options.users.primaryUser;
        };
      };

      commonModules = {
        system = import ./system/system.nix;
        system-shells = import ./system/shell.nix;
        users-primaryUser = import ./modules/user.nix;
        programs-nix-index = import ./system/nix-index.nix;
      };

      # `nix-darwin` modules that are pending upstream, or patched versions waiting on upstream
      # fixes.
      darwinModules = {
        system-darwin = import ./system/darwin/system.nix;
        system-darwin-packages = import ./system/darwin/packages.nix;
        system-darwin-security-pam = import ./system/darwin/security.nix;
        system-darwin-gpg = import ./system/darwin/gpg.nix;
        system-darwin-homebrew = import ./system/darwin/homebrew.nix;
      };

    } // flake-utils.lib.eachDefaultSystem (system: {
      legacyPackages = import inputs.nixpkgs-unstable {
        inherit system;
        inherit (nixpkgsConfig) config;
        overlays = with self.overlays; [
          pkgs-master
          pkgs-stable
          apple-silicon
        ];
      };
    });
}