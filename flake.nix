{
  description = "Budhilaw Nix Configuration";

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];

      imports = [
        inputs.pre-commit-hooks.flakeModule
        ./nix
        # ./nvim.nix
      ];
    };

  inputs = {
    nix.url = "github:nixos/nix";
    nix.inputs.nixpkgs.follows = "nixpkgs";

    # utilities for Flake
    flake-parts.url = "github:hercules-ci/flake-parts";

    ## -- nixpkgs 
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.follows = "nixpkgs-unstable";

    ## -- Platform

    #### ---- MacOS
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    #### ---- Home
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #### ---- nixvim
    # nixvim.url = "github:nix-community/nixvim";
    # nixvim.inputs.nixpkgs.follows = "nixpkgs";
    # nixvim.inputs.nix-darwin.follows = "nix-darwin";
    # nixvim.inputs.home-manager.follows = "home-manager";
    # nixvim.inputs.flake-parts.follows = "flake-parts";

    # neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    # neorg-overlay.inputs.nixpkgs.follows = "nixpkgs";

    # utilities
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    nix-env = {
      url = "github:lilyball/nix-env.fish";
      flake = false;
    };
  };
}
