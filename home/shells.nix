{ config, pkgs, lib, ... }:

let
  inherit (config.home.user-info) nixConfigDirectory;
  inherit (lib) mkAfter;
  shellAliases = with pkgs; {
    # Nix related
    drb = "darwin-rebuild build --flake ${nixConfigDirectory}";
    drs = "darwin-rebuild switch --flake ${nixConfigDirectory}";

    # lenv show list generations aka list build version
    # senv switch generation <number>
    # denv delete generation <number>
    # renv rollback to previous version number
    # param: <GENEREATION_NUMBER> 
    # run lenv before if you want to see <GENEREATION_NUMBER>
    lenv = "nix-env --list-generations";
    senv = "nix-env --switch-generation";
    denv = "nix-env --delete-generations";
    doenv = "denv old";
    renv = "nix-env --rollback";

    # is equivalent to: nix build --recreate-lock-file
    flakeup = "nix flake update ${nixConfigDirectory}";
    nb = "nix build";
    nd = "nix develop";
    nf = "nix flake";
    nr = "nix run";
    ns = "nix search";
  };
in
{
  home = with pkgs;{
    shellAliases = shellAliases;
    sessionVariables = {
      RUST_SRC_PATH = "${rust.packages.stable.rustPlatform.rustLibSrc}";
    };
    packages = with fishPlugins;[
      # https://github.com/franciscolourenco/done
      done
      # use babelfish than foreign-env
      foreign-env
      # https://github.com/wfxr/forgit
      forgit
      # Paired symbols in the command line
      pisces
    ];
  };

  xdg.configFile."fish/conf.d/plugin-git-now.fish".text = mkAfter ''
    for f in $plugin_dir/*.fish
      source $f
    end
  '';

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

      functions = {
        gitignore = "curl -sL https://www.gitignore.io/api/$argv";
      };

      interactiveShellInit = ''
        # Fish color
        set -U fish_color_command 6CB6EB --bold
        set -U fish_color_redirection DEB974
        set -U fish_color_operator DEB974
        set -U fish_color_end C071D8 --bold
        set -U fish_color_error EC7279 --bold
        set -U fish_color_param 6CB6EB
        set fish_greeting
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
          format = "[$symbol$branch]($style) ";
        };
        gcloud = {
          format = "[$symbol$active]($style) ";
        };
      };
    };
  };
}