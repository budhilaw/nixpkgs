{ pkgs, lib, ... }:

{

  # https://devenv.sh/packages/
  packages = [ pkgs.git ];

  # enterShell = ''
  #   export GOBIN=$GOPATH/bin:$HOME/Dev/Golang/bin
  #   export GOPATH=$GOPATH:$HOME/Dev/Golang
  #   export GOPRIVATE="github.com/paper-indonesia/*"
  #   export CC="/Library/Developer/CommandLineTools/usr/bin/gcc"
  # '';

  # https://devenv.sh/languages/
  languages.nix.enable = true;
  languages.go.enable = true;
  languages.go.package = pkgs.go;

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
