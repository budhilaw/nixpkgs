{ pkgs, precommit, devenv }:
{

  # `nix develop my`.
  default = pkgs.mkShell {
    description = "Budhilaw nixpkgs development environment";
    shellHook = precommit.shellHook or '''';
    buildInputs = precommit.buildInputs or [ ];
    packages = precommit.packages or [ ];
  };

  # go = devenv.lib.mkShell {
  #   modules = [
  #     ({ pkgs, ... }: {
  #       # This is your devenv configuration
  #       packages = [ pkgs.hello ];

  #       enterShell = ''
  #         hello
  #       '';

  #       processes.run.exec = "hello";
  #     })
  #   ];
  # };

  # `nix develop my#go`.
  # go = pkgs.mkShellNoCC {
  #   description = "Go Development Environment";
  #   buildInputs = with pkgs; [
  #     # Go-lang
  #     go
  #     gopls
  #     gotools
  #     golangci-lint

  #     # MariaDB
  #     mariadb
  #   ];

  #   shellHook = ''
  #     ${pkgs.go}/bin/go version
  #   '';
  # };

}