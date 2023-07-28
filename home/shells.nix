{ config, pkgs, lib, ... }:

let
  inherit (config.home.user-info) nixConfigDirectory;
  inherit (lib) mkAfter;
in
{

  programs = {
    # jump like `z` or `fasd` 
    dircolors.enable = true;
    # Fish Shell (Default shell)
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.fish.enable
    fish = {
      enable = true;
      # Fish plugins 
      # See: 
      # https://github.com/NixOS/nixpkgs/tree/90e20fc4559d57d33c302a6a1dce545b5b2a2a22/pkgs/shells/fish/plugins 
      # for list available plugins built-in nixpkgs
      plugins = with pkgs.fishPlugins;[
        {
          name = "nix-env";
          src = pkgs.fetchFromGitHub {
            owner = "lilyball";
            repo = "nix-env.fish";
            rev = "7b65bd228429e852c8fdfa07601159130a818cfa";
            sha256 = "069ybzdj29s320wzdyxqjhmpm9ir5815yx6n522adav0z2nz8vs4";
          };
        }
      ];

      interactiveShellInit = ''
        # Fish color
        set -U fish_color_command 6CB6EB --bold
        set -U fish_color_redirection DEB974
        set -U fish_color_operator DEB974
        set -U fish_color_end C071D8 --bold
        set -U fish_color_error EC7279 --bold
        set -U fish_color_param 6CB6EB
        set fish_greeting

        # direnv
        direnv hook fish | source
        direnv export fish | source

        # Golang
        # fish_add_path /${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.home.username}/Dev/Golang/bin
        # set -gx GOPATH $HOME/Development/Golang/:$HOME/Development/Paper/Golang
        # set -gx GOPATH $HOME/Development/Golang/
        # set -gx GOPRIVATE "github.com/paper-indonesia/*"
        # set -gx CC /Library/Developer/CommandLineTools/usr/bin/gcc

        # Jetbrains
        fish_add_path /${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.home.username}/Library/Application\ Support/JetBrains/Toolbox/scripts

        # brew bin
        fish_add_path /opt/homebrew/bin

        # Aliases
        alias dev="cd $HOME/Dev/"
        alias personaldev="cd $HOME/Dev/Personal"
        alias paperdev="cd $HOME/Dev/Paper"
        alias nixdir="cd ~/.config/nixpkgs"
        alias di="devenv init"
        alias ds="devenv shell -c $SHELL"
      '';
    };

    # Fish prompt and style
    starship = {
      enable = true;
      settings = {
        add_newline = true;
        command_timeout = 1000;
        cmd_duration = {
          format = " [$duration]($style) ";
          style = "bold #EC7279";
          show_notifications = true;
        };
        nix_shell = {
          format = " [$symbol$state]($style) ";
        };
        battery = {
          full_symbol = "🔋 ";
          charging_symbol = "⚡️ ";
          discharging_symbol = "💀 ";
        };
        git_branch = {
          # symbol = "🌱 ";
          format = "[$symbol$branch]($style) ";
        };
        gcloud = {
          disabled = true;
        };
      };
    };
  };
}
