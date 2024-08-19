##################################################################
#                       Development shells
##################################################################
{ pkgs, precommit }:

{
  default = pkgs.mkShell {
    description = "default nixpkgs development environment";
    shellHook = precommit.shellHook or '''';
    buildInputs = precommit.buildInputs or [ ];
    packages = precommit.packages or [ ];
  };

  node18 = pkgs.mkShell {
    description = "Node.js 18 Development Environment";
    buildInputs = with pkgs; [
      nodejs_18
      (nodePackages.yarn.override { nodejs = nodejs_18; })
    ];
  };

  go = pkgs.mkShell {
    description = "Go Development Environment";
    nativeBuildInputs = [ pkgs.go ];
    shellHook = ''
      export GOPATH="$(${pkgs.go}/bin/go env GOPATH)"
      export PATH="$PATH:$GOPATH/bin"
    '';
  };

  pnpm = pkgs.mkShell {
    description = "Nodejs with PNPM";

    buildInputs = with pkgs; [
      nodejs_21
      (nodePackages.pnpm.override { nodejs = nodejs_21; })
    ];
  };

  rust-wasm = pkgs.mkShell {
    # declared ENV variables when starting shell
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

    nativeBuildInputs = with pkgs; [ rustc cargo gcc rustfmt clippy ];
  };
}