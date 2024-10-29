##################################################################
#                       Development shells
##################################################################
{ self, ... }:

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

          #
          #
          #    $ nix develop github:budhilaw/nixpkgs#php-nginx
          #
          #
          php-nginx = pkgs.mkShell {
            description = "PHP 8.3 with Nginx Development Environment";
            
            buildInputs = with pkgs; [
              php83
              nginx
              mysql80
            ];

            shellHook = ''
              # Environment variables
              export DBNAME="personal_blog"
              export DBUSER="myusername"
              export HOSTNAME="localhost"

              # PHP-FPM configuration
              mkdir -p /tmp/php-fpm
              cat > /tmp/php-fpm/php-fpm.conf << EOF
              [global]
              pid = /tmp/php-fpm/php-fpm.pid
              error_log = /tmp/php-fpm/php-fpm.log

              [www]
              listen = 127.0.0.1:9000
              pm = dynamic
              pm.max_children = 5
              pm.start_servers = 2
              pm.min_spare_servers = 1
              pm.max_spare_servers = 3
              EOF

              # PHP configuration
              cat > /tmp/php-fpm/php.ini << EOF
              memory_limit = 256M
              EOF

              # Nginx configuration
              mkdir -p /tmp/nginx
              cat > /tmp/nginx/nginx.conf << EOF
              worker_processes auto;
              pid /tmp/nginx/nginx.pid;
              error_log /tmp/nginx/error.log;

              events {
                  worker_connections 1024;
              }

              http {
                  include ${pkgs.nginx}/conf/mime.types;
                  access_log /tmp/nginx/access.log;

                  server {
                      listen 80;
                      server_name localhost;
                      
                      root \$PWD/public;
                      index index.php index.html index.htm;
                      
                      location / {
                          try_files \$uri \$uri/ /index.php?\$args;
                      }
                      
                      location ~ \.php$ {
                          fastcgi_split_path_info ^(.+\.php)(/.+)$;
                          fastcgi_pass 127.0.0.1:9000;
                          fastcgi_index index.php;
                          include ${pkgs.nginx}/conf/fastcgi_params;
                          include ${pkgs.nginx}/conf/fastcgi.conf;
                          fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                          fastcgi_param PATH_INFO \$fastcgi_path_info;
                      }

                      location ~ /\.ht {
                          deny all;
                      }
                      
                      location /api {
                          proxy_pass http://localhost:3000;
                          proxy_http_version 1.1;
                          proxy_set_header Upgrade \$http_upgrade;
                          proxy_set_header Connection 'upgrade';
                          proxy_set_header Host \$host;
                          proxy_cache_bypass \$http_upgrade;
                      }
                      
                      add_header X-Frame-Options "SAMEORIGIN";
                      add_header X-XSS-Protection "1; mode=block";
                      add_header X-Content-Type-Options "nosniff";
                      
                      gzip on;
                      gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
                      
                      error_page 404 /404.html;
                      error_page 500 502 503 504 /50x.html;
                  }
              }
              EOF

              # MySQL configuration
              mkdir -p /tmp/mysql
              if [ ! -d "/tmp/mysql/data" ]; then
                mysql_install_db --datadir=/tmp/mysql/data
                mysqld --datadir=/tmp/mysql/data --pid-file=/tmp/mysql/mysql.pid &
                sleep 10
                mysql -u root << EOF
                CREATE DATABASE IF NOT EXISTS personal_blog;
                CREATE USER IF NOT EXISTS 'myusername'@'localhost' IDENTIFIED BY 'mypassword';
                GRANT ALL PRIVILEGES ON *.* TO 'myusername'@'localhost';
                FLUSH PRIVILEGES;
                EOF
              fi

              # Start services
              echo "Starting PHP-FPM..."
              php-fpm -y /tmp/php-fpm/php-fpm.conf -c /tmp/php-fpm/php.ini

              echo "Starting Nginx..."
              nginx -c /tmp/nginx/nginx.conf

              echo "Starting MySQL..."
              if [ ! -f "/tmp/mysql/mysql.pid" ]; then
                mysqld --datadir=/tmp/mysql/data --pid-file=/tmp/mysql/mysql.pid &
              fi

              echo "Development environment is ready!"
              echo "PHP-FPM running on 127.0.0.1:9000"
              echo "Nginx running on http://localhost:80"
              echo "MySQL running on localhost:3306"

              # Cleanup on exit
              trap 'pkill php-fpm; nginx -s quit; mysqladmin -u root shutdown' EXIT
            '';
          };
        };
    };
}
