##################################################################
#                       Development shells
##################################################################
{ self, inputs, ... }:

{
  perSystem =
    { pkgs, config, ... }:
    {
      pre-commit.check.enable = true;
      pre-commit.devShell = self.devShells.default;
      pre-commit.settings.hooks = {
        actionlint.enable = true;
        shellcheck.enable = true;
        deadnix.enable = true;
        deadnix.excludes = [ "nix/overlays/nodePackages/node2nix" ];
        nixfmt-rfc-style.enable = true;
      };

      devShells =
        let
          inherit (pkgs) lib;
          inherit (inputs) devenv;

          mutFirstChar =
            f: s:
            let
              firstChar = f (lib.substring 0 1 s);
              rest = lib.substring 1 (-1) s;

            in
            # matched = builtins.match "(.)(.*)" s;
            # firstChar = f (lib.elemAt matched 0);
            # rest = lib.elemAt matched 1;
            firstChar + rest;

          toCamelCase_ =
            sep: s:
            mutFirstChar lib.toLower (lib.concatMapStrings (mutFirstChar lib.toUpper) (lib.splitString sep s));

          toCamelCase =
            s:
            builtins.foldl' (s: sep: toCamelCase_ sep s) s [
              "-"
              "_"
              "."
            ];

          mkNodeShell =
            name:
            let
              node = pkgs.${name};
              corepackShim = pkgs.nodeCorepackShims.overrideAttrs (_: {
                buildInputs = [ node ];
              });
            in
            pkgs.mkShell {
              description = "${name} Development Environment";
              buildInputs = [
                node
                corepackShim
              ];
            };

          mkGoShell =
            name:
            let
              go = pkgs.${name};
            in
            pkgs.mkShell {
              description = "${name} Development Environment";
              buildInputs = [ go ];
              shellHook = ''
                export GOPATH="$(${go}/bin/go env GOPATH)"
                export PATH="$PATH:$GOPATH/bin"
              '';
            };

          mkShell =
            pkgName: name:
            if lib.strings.hasPrefix "nodejs_" pkgName then
              mkNodeShell name
            else if lib.strings.hasPrefix "go_" pkgName then
              mkGoShell name
            else
              builtins.throw "Unknown package ${pkgName} for making shell environment";

          mkShells =
            pkgName:
            let
              mkShell_ = mkShell pkgName;
            in
            builtins.foldl' (acc: name: acc // { "${toCamelCase name}" = mkShell_ name; }) { } (
              builtins.filter (lib.strings.hasPrefix pkgName) (builtins.attrNames pkgs)
            );

        in
        ####################################################################################################
        #    see nodejs_* definitions in {https://search.nixos.org/packages?query=nodejs_}
        #
        #    versions: 14, 18, 20, 22, Latest
        #
        #    $ nix develop github:budhilaw/nixpkgs#<nodejsVERSION>
        #
        #
        mkShells "nodejs_"
        // mkShells "go_"
        // {
          default = pkgs.mkShell {
            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };

          php-nginx = devenv.lib.mkShell {
            inherit pkgs;
            modules = [
              ({ pkgs, config, ... }: {
                # This is your devenv configuration
                packages = [ pkgs.hello ];

                enterShell = ''
                  hello
                '';

                processes.run.exec = "hello";
              })
            ];
          };

          #
          #
          #    $ nix develop github:budhilaw/nixpkgs#go
          #
          #
          go = pkgs.mkShell {
            description = "Go Development Environment";
            nativeBuildInputs = [ pkgs.go ];
            shellHook = ''
              export GOPATH="$(${pkgs.go}/bin/go env GOPATH)"
              export PATH="$PATH:$GOPATH/bin"
            '';
          };

          #
          #
          #    $ nix develop github:budhilaw/nixpkgs#rust-wasm
          #
          #
          rust = pkgs.mkShell {
            description = "Rust Development Environment with rustup";
            
            nativeBuildInputs = with pkgs; [
              # System dependencies
              pkg-config
              curl
              gcc
              openssl.dev
              # Required for some Rust crates
              libiconv
              # Required for wasm-pack
              wasm-pack
            ];

            buildInputs = with pkgs; [
              rustup  # Using rustup instead of specific Rust version
            ];

            shellHook = ''
              # Initialize rustup if not already done
              if ! command -v rustup &> /dev/null; then
                rustup-init -y --no-modify-path
              fi
              
              # Add cargo bin to PATH
              export PATH=$HOME/.cargo/bin:$PATH
              
              # For openssl-sys
              export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
              
              # For custom target directory within the project
              export CARGO_TARGET_DIR="target"
              
              # Ensure target directory exists
              mkdir -p $CARGO_TARGET_DIR
            '';
          };

          #
          #
          #    $ nix develop github:budhilaw/nixpkgs#bun
          #
          #
          bun = pkgs.mkShell { buildInputs = [ pkgs.bun ]; };
        };
    };
}
