{ config, pkgs, ... }:

let
  inherit (pkgs.stdenv) isDarwin;
in
{
  # Packages with configuration --------------------------------------------------------------- {{{
  programs.home-manager.enable = true;

  programs.nix-index.enable = true;

  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = {
    style = "plain";
    theme = "Catppuccin Frappe";
  };

  # https://direnv.net
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
  programs.direnv.enable = true;
  programs.direnv.silent = true;
  programs.direnv.nix-direnv.enable = true;

  # Htop
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.btop.enable
  programs.btop.enable = true;
  programs.btop.settings = {
    vim_keys = true;
    show_battery = false;
  };

  home.packages = with pkgs;
    [
      ################################## 
      # Productivity
      ##################################
      # neofetch # fancy fetch information
      lsd
      htop
      tldr
      jq
      fd
      wget
      curl
      eza

      ################################## 
      # Development
      ##################################
      neovim
      vscode
      postman
      pkg-config
      git
      sops
      # cloudflared
      mkcert
      docker
      kubectl
      orbstack
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])

      ################################## 
      # Programming Stuff
      ##################################
      mysql84
      python3
      go-mockery
      go-migrate
      docker
      sequel-ace
      jetbrains-toolbox

      ################################## 
      # Shell Integrations
      ################################## 
      starship # theme for shell (bash,fish,zsh)
      tmux

      ################################## 
      # Misc
      ################################## 
      gnupg
      openssl
      raycast
      arc-browser
      cloudflare-warp
      iina
      hidden-bar
      appcleaner
      ffmpeg
      obs-studio
      telegram
      shottr
      obsidian
      notion
      iterm2

      ################################## 
      # Useful Nix related tools
      ################################## 
      cachix
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
