{ pkgs, precommit }:
{
  #
  #
  #    $ nix develop github:budhilaw/nixpkgs
  #
  #
  default = pkgs.mkShell {
    description = "Budhilaw nixpkgs development environment";
    shellHook = precommit.shellHook or '''';
    buildInputs = precommit.buildInputs or [ ];
    packages = precommit.packages or [ ];
  };

  php8 = pkgs.mkShell {
    description = "PHP 8.1";
    buildInputs = with pkgs; [
      env-php81
    ];
  };

  #
  #
  #    $ nix develop github:budhilaw/nixpkgs#node18
  #
  #
  node18 = pkgs.mkShell {
    description = "Node.js 18 Development Environment";
    buildInputs = with pkgs; [
      nodejs_18
      (nodePackages.yarn.override { nodejs = nodejs_18; })
    ];
  };

  #
  #
  #    $ nix develop github:r17x/nixpkgs#pnpm
  #
  #
  pnpm = pkgs.mkShell {
    description = "Nodejs with PNPM";

    buildInputs = with pkgs; [
      nodejs_18
      (nodePackages.pnpm.override { nodejs = nodejs_18; })
    ];
  };

  #
  #
  #    $ nix develop github:r17x/nixpkgs#rust-wasm
  #
  #
  rust-wasm = pkgs.mkShell {
    # declared ENV variables when starting shell
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

    nativeBuildInputs = with pkgs; [ rustc cargo gcc rustfmt clippy ];
  };
}