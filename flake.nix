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
        inputs.devenv.flakeModule
        ./nix
      ];
    };

  inputs = {
    nix.url = "github:nixos/nix";
    nix.inputs.nixpkgs.follows = "nixpkgs";

    # utilities for Flake
    flake-parts.url = "github:hercules-ci/flake-parts";

    ## -- nixpkgs 
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs.follows = "nixpkgs-unstable";

    ## -- Platform

    #### ---- MacOS
    # nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    #### ---- Home
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    iamb.url = "github:ulyssa/iamb";
    iamb.inputs.nixpkgs.follows = "nixpkgs";

    # utilities
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
    pre-commit-hooks.inputs.nixpkgs.follows = "nixpkgs";

    # devenv for development environments
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    # others 
    nix-env = {
      url = "github:lilyball/nix-env.fish";
      flake = false;
    };
  };
}
