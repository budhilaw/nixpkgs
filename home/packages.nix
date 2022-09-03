{ config, pkgs, lib, ... }:

{
  # Packages with configuration --------------------------------------------------------------- {{{
  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.htop.enable
  programs.htop.enable = true;
  programs.htop.settings.show_program_path = true;

  programs.gpg = {
    enable = true;
    settings = {
      use-agent = true;
    };
  };

  # creating file with contents, that file will stored in nix-store
  # then symlink to homeDirectory.
  home.file.".gnupg/gpg-agent.conf".source = pkgs.writeTextFile {
    name = "home-gpg-agent.conf";
    text = lib.optionalString (pkgs.stdenv.isDarwin) ''
      use-standard-socket
      enable-ssh-support
      default-cache-ttl 600
      max-cache-ttl 7200
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    '';
  };

  home.packages = with pkgs;
    [
      ################################## 
      # common
      ##################################
      coreutils
      cascadia-code
      htop
      curl
      wget
      tree
      gnupg # required for pass git

      ################################## 
      # Manager
      ################################## 
      # yadm 

      ################################## 
      # Productivity
      ################################## 
      neofetch # fancy fetch information
      fd # fancy find
      jq # JSON in shell
      ripgrep # another yet of grep

      ################################## 
      # Development
      ##################################
      google-cloud-sdk
      paperkey
      shellcheck
      rustPackages.rustc
      rustPackages.rustfmt
      rustPackages.cargo
      python3

      ################################## 
      # Shell Integrations
      ################################## 
      starship # theme for shell (bash,fish,zsh)

      ################################## 
      # Useful Nix related tools
      ################################## 
      cachix
      comma # run without install
      home-manager
      nix-prefetch-git
      niv # easy dependency management for nix projects
      nix-tree # interactively browse dependency graphs of Nix derivations
      nix-update # swiss-knife for updating nix packages
      nixpkgs-review # review pull-requests on nixpkgs
      statix # lints and suggestions for the Nix programming language
  ] ++ lib.optionals stdenv.isDarwin [
    m-cli # useful macOS CLI commands
    xcode-install
  ];
}