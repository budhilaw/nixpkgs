{
  description = "ri7's nix darwin system";

  inputs = {
    # Package sets
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixpkgs-23.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Flake utilities
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager inputs
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # pvt
    pvt.url = "github:budhilaw-paper/dvt";
    pvt.inputs.nixpkgs.follows = "nixpkgs";

    # utilities
    precommit.url = "github:cachix/pre-commit-hooks.nix";
    precommit.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , darwin
    , home-manager
    , flake-utils
    , ...
    } @inputs:

    let
      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs-unstable.lib) attrValues makeOverridable singleton optionalAttrs;
      # Overlays --------------------------------------------------------------------------------{{{

      config = { allowUnfree = true; };

      overlays =
        {
          # Overlays Package Sets ---------------------------------------------------------------{{{
          # Overlays to add different versions `nixpkgs` into package set
          pkgs-master = _: prev: {
            pkgs-master = import inputs.nixpkgs-master {
              inherit (prev.stdenv) system;
              inherit config;
            };
          };
          pkgs-stable = _: prev: {
            pkgs-stable = import inputs.nixpkgs-stable {
              inherit (prev.stdenv) system;
              inherit config;
            };
          };
          pkgs-unstable = _: prev: {
            pkgs-unstable = import inputs.nixpkgs-unstable {
              inherit (prev.stdenv) system;
              inherit config;
            };
          };
          apple-silicon = _: prev: optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            # Add access to x86 packages system is running Apple Silicon
            pkgs-x86 = import inputs.nixpkgs {
              system = "x86_64-darwin";
              inherit config;
            };
          };
        };

      # }}}

      # default configurations --------------------------------------------------------------{{{
      # Configuration for `nixpkgs`
      defaultNixpkgs = {
        inherit config;
        overlays = attrValues overlays
          ++ singleton (inputs.pvt.overlay);
      };

      # Personal configuration shared between `nix-darwin` and plain `home-manager` configs.
      homeManagerStateVersion = "23.05";

      primaryUserInfo = rec {
        username = "budhilaw";
        fullName = "Ericsson Budhilaw";
        email = "budhilaw@icloud.com";
        nixConfigDirectory = "/Users/${username}/.config/nixpkgs";
      };

      # Modules shared by most `nix-darwin` personal configurations.
      nixDarwinCommonModules = attrValues self.commonModules
        ++ attrValues self.darwinModules
        ++ [
        # `home-manager` module
        home-manager.darwinModules.home-manager
        (
          { config, pkgs, ... }:
          let
            inherit (config.users) primaryUser;
          in
          {
            nixpkgs = defaultNixpkgs;
            # Hack to support legacy worklows that use `<nixpkgs>` etc.
            nix.nixPath = { nixpkgs = "${inputs.nixpkgs}"; };
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
            nix.registry = {
              my.flake = self;
              pvt.flake = inputs.pvt;
            };
          }
        )
      ];

      # }}}
    in
    {

      # Modules --------------------------------------------------------------------------------{{{
      darwinConfigurations = rec {
        # TODO refactor darwin.nix to make common or bootstrap configuration
        bootstrap-x86 = makeOverridable darwinSystem {
          system = "x86_64-darwin";
          modules = attrValues self.commonModules;
        };

        bootstrap-arm = bootstrap-x86.override { system = "aarch64-darwin"; };

        budhilaw = bootstrap-arm.override {
          modules = nixDarwinCommonModules ++ [
            {
              users.primaryUser = primaryUserInfo;
              networking.computerName = "budhilaw";
              networking.hostName = "localghost";
              networking.knownNetworkServices = [
                "Wi-Fi"
                "USB 10/100/1000 LAN"
              ];
            }
          ];
        };
      };

      homeConfigurations.budhilaw =
        let
          pkgs = import inputs.nixpkgs (defaultNixpkgs // { system = "aarch64-darwin"; });
        in
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = attrValues self.homeManagerModules
          ++ singleton ({ config, ... }: {
            home.username = config.home.user-info.username;
            home.homeDirectory = "/${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.home.username}";
            home.stateVersion = homeManagerStateVersion;
            home.user-info = primaryUserInfo // {
              nixConfigDirectory = "${config.home.homeDirectory}/.config/nixpkgs";
            };
          });
        };

      # `home-manager` modules
      homeManagerModules = {
        home-activation = import ./home/activation.nix;
        home-packages = import ./home/packages.nix;
        home-shells = import ./home/shells.nix;
        home-ssh = import ./home/ssh.nix;
        home-git = import ./home/git.nix;

        home-user-info = { lib, ... }: {
          options.home.user-info =
            (self.commonModules.users-primaryUser { inherit lib; }).options.users.primaryUser;
        };
      };

      commonModules = {
        system = import ./system/system.nix;
        system-shells = import ./system/shells.nix;
        users-primaryUser = import ./modules/user.nix;
        programs-nix-index = import ./system/nix-index.nix;
      };

      # fixes.
      darwinModules = {
        system-darwin = import ./system/darwin/system.nix;
        system-darwin-packages = import ./system/darwin/packages.nix;
        system-darwin-gpg = import ./system/darwin/gpg.nix;
        system-darwin-homebrew = import ./system/darwin/homebrew.nix;
      };

      # }}}

    } // flake-utils.lib.eachDefaultSystem (system: rec {

      legacyPackages = import inputs.nixpkgs-unstable (defaultNixpkgs // { inherit system; });

      # Checks ----------------------------------------------------------------------{{{
      # e.g., run `nix flake check` in $HOME/.config/nixpkgs.

      checks = {
        pre-commit-check = inputs.precommit.lib.${system}.run {
          src = ./.;
          # you can enable more hooks here {https://github.com/cachix/pre-commit-hooks.nix/blob/a4548c09eac4afb592ab2614f4a150120b29584c/modules/hooks.nix}
          hooks = {
            actionlint.enable = true;
            shellcheck.enable = true;
            stylua.enable = true;
            # TODO https://github.com/cachix/pre-commit-hooks.nix/issues/196
            # make override and pass configuration
            luacheck.enable = false;

            # .nix related
            deadnix.enable = true;
            nixpkgs-fmt.enable = true;
          };
        };
      };

      # }}}

      # Development shells ----------------------------------------------------------------------{{{
      # Shell environments for development
      # With `nix.registry.my.flake = inputs.self`, development shells can be created by running,
      # e.g., `nix develop my#node`. 

      devShells = import ./devShells.nix {
        pkgs = self.legacyPackages.${system};
        precommit = checks.pre-commit-check;
      };

      # }}}

    });
}

# vim: foldmethod=marker
