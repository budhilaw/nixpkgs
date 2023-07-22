{ pkgs, precommit }:
{

  # `nix develop my`.
  default = pkgs.mkShell {
    description = "Budhilaw nixpkgs development environment";
    shellHook = precommit.shellHook or '''';
    buildInputs = precommit.buildInputs or [ ];
    packages = precommit.packages or [ ];
  };

  # `nix develop my#go`.
  go = pkgs.mkShellNoCC {
    description = "Go Development Environment";
    buildInputs = with pkgs; [
      go

      # go lsp
      gopls

      # goimports, godoc, etc.
      gotools

      # https://github.com/golangci/golangci-lint
      golangci-lint
    ];

    shellHook = ''
      ${pkgs.go}/bin/go version
    ''
  };

}