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
            inherit inputs pkgs;
            modules = [
              ({ pkgs, config, ... }: {
                env.DBNAME = "personal_blog";
                env.DBUSER = "myusername";
                env.HOSTNAME = "localhost";

                packages = with pkgs; [ ];

                # Enable PHP-FPM languages
                languages.php = {
                  enable = true;
                  version = "8.3";
                  ini = ''
                    memory_limit = 256M
                  '';
                  fpm.pools.web = {
                    settings = {
                      "listen" = "127.0.0.1:9000";
                      "pm" = "dynamic";
                      "pm.max_children" = 5;
                      "pm.start_servers" = 2;
                      "pm.min_spare_servers" = 1;
                      "pm.max_spare_servers" = 3;
                    };
                  };
                };

                # see full options: https://devenv.sh/supported-services/mysql/
                services.mysql.enable = true;
                services.mysql.package = pkgs.mysql80;
                services.mysql.ensureUsers = [
                  {
                    name = "myusername";
                    password = "mypassword";
                    ensurePermissions = {
                      "database.*" = "ALL PRIVILEGES";
                      "*.*" = "ALL PRIVILEGES";
                    };
                  }
                ];
                services.mysql.initialDatabases = [{ name = "personal_blog"; }];

                # see full options: https://devenv.sh/supported-services/nginx/
                # Nginx configuration
                services.nginx = {
                  enable = true;
                  
                  # HTTP configuration
                  httpConfig = ''
                    # Default server block
                    server {
                        listen 80;
                        server_name localhost;
                        
                        # Root directory set to the same directory as flake.nix
                        root ${config.env.DEVENV_ROOT}/public;
                        
                        # Default index files - added index.php
                        index index.php index.html index.htm;
                        
                        # Basic location block for the root path
                        location / {
                            try_files $uri $uri/ /index.php?$args;
                        }
                        
                        # PHP handling
                        location ~ \.php$ {
                            fastcgi_split_path_info ^(.+\.php)(/.+)$;
                            fastcgi_pass 127.0.0.1:9000;
                            fastcgi_index index.php;
                            include ${pkgs.nginx}/conf/fastcgi_params;
                            include ${pkgs.nginx}/conf/fastcgi.conf;
                            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                            fastcgi_param PATH_INFO $fastcgi_path_info;
                        }

                        # Deny access to .htaccess files
                        location ~ /\.ht {
                            deny all;
                        }
                        
                        # Example API proxy
                        location /api {
                            proxy_pass http://localhost:3000;
                            proxy_http_version 1.1;
                            proxy_set_header Upgrade $http_upgrade;
                            proxy_set_header Connection 'upgrade';
                            proxy_set_header Host $host;
                            proxy_cache_bypass $http_upgrade;
                        }
                        
                        # Security headers
                        add_header X-Frame-Options "SAMEORIGIN";
                        add_header X-XSS-Protection "1; mode=block";
                        add_header X-Content-Type-Options "nosniff";
                        
                        # Enable gzip compression
                        gzip on;
                        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
                        
                        # Error pages
                        error_page 404 /404.html;
                        error_page 500 502 503 504 /50x.html;
                    }
                  '';
                };

                scripts.up.exec = ''
                  devenv up
                '';
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
