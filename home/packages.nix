{ config, pkgs, lib, ... }:

{
  # Packages with configuration --------------------------------------------------------------- {{{

  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = {
    style = "plain";
    theme = "TwoDark";
  };

  # Direnv, load and unload environment variables depending on the current directory.
  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

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
      pinentry-program ${pkgs.pinentry_mac}/Applications/pinentry-mac.app/Contents/MacOS/pinentry-mac
    '';
  };

  home.packages = with pkgs;
    [
      ################################## 
      # Productivity
      ##################################
      neofetch # fancy fetch information
      lsd
      ncdu
      htop
      tldr
      jq
      fd
      wget
      curl
      exa

      ################################## 
      # Development
      ##################################
      pkg-config
      git
      sops
      cloudflared
      docker
      graphviz
      # neovim
      # google-cloud-sdk

      ################################## 
      # Shell Integrations
      ################################## 
      starship # theme for shell (bash,fish,zsh)

      ################################## 
      # Misc
      ################################## 
      # obs-studio
      openssl

      ################################## 
      # Useful Nix related tools
      ################################## 
      cachix
      rnix-lsp
      home-manager
      nix-prefetch-git

    ] ++ lib.optionals
      stdenv.isDarwin
      [
        mas
        m-cli # useful macOS CLI commands
        xcode-install
        rectangle
        discord
        zoom-us
      ];
}