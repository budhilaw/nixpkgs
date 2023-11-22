{ config, pkgs, lib, ... }:

let
  inherit (config.home.user-info) nixConfigDirectory;
  inherit (lib) mkAfter;

  commandFoldl' = builtins.foldl' (a: b: a + b + '' &&'') '''';
  shellAliases = with pkgs;
    {
      # Nix related
      nclean = commandFoldl' [
        "nix profile wipe-history"
        "nix-collect-garbage"
        "nix-collect-garbage -d"
        "nix-collect-garbage --delete-old"
        "nix store gc"
        "nix store optimise"
        "nix-store --verify --repair --check-contents"
      ];
      drb = "darwin-rebuild build --flake ${nixConfigDirectory}";
      drs = "darwin-rebuild switch --flake ${nixConfigDirectory}";
      psc0 = "nix build ${nixConfigDirectory}#darwinConfigurations.budhilaw.system --json | jq -r '.[].outputs | to_entries[].value' | cachix push budhilaw";
      
      # is equivalent to: nix build --recreate-lock-file
      flakeup-all = "nix flake update ${nixConfigDirectory}";
      # example: 
      # $ flakeup home-manager
      flakeup = "nix flake lock ${nixConfigDirectory} --update-input";
      nb = "nix build";
      ndp = "nix develop";
      nf = "nix flake";
      nr = "nix run";
      ns = "nix-shell";
      nq = "nix search";
      
      # Cryptography
      # age = "${rage}/bin/rage";

      # Devenv related
      di = "devenv init";
      ds = "devenv shell -c $SHELL";

      # Shell related
      dev = "cd $HOME/Dev/";
      grep = "${ripgrep}/bin/rg";
      ll = "exa -l -g --icons --git";
      l = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      lt = "ls --tree";
      cat = "${bat}/bin/bat";
      du = "${du-dust}/bin/dust";
      git = "${git}/bin/git";
      pullhead = "git pull origin (git rev-parse --abbrev-ref HEAD)";
      plh = "pullhead";
      pushhead = "git push origin (git rev-parse --abbrev-ref HEAD)";
      psh = "pushhead";
      gi = "gitignore";
      g = "git";
      gtemp = "git commit -m \"temp\" --no-verify";
      gf = "git flow";
      gl = "git log --graph --oneline --all";
      gll = "git log --oneline --decorate --all --graph --stat";
      gld = "git log --oneline --all --pretty=format:\"%h%x09%an%x09%ad%x09%s\"";
      gls = "gl --show-signature";
      gfa = "git fetch --all";
      grc = "git rebase --continue";
      rm = "rm -i";

      # Development
      # docker = "${pkgs.podman}/bin/podman";
      # docker-compose = "${pkgs.podman-compose}/bin/podman-compose";
    };
in
{

  home = with pkgs;{
    shellAliases = shellAliases;
  };

  programs = {
    # jump like `z` or `fasd` 
    dircolors.enable = true;
    # Fish Shell (Default shell)
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.fish.enable
    fish = {
      enable = true;
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

        # Jetbrains
        fish_add_path /${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.home.username}/Library/Application\ Support/JetBrains/Toolbox/scripts

        # brew bin
        fish_add_path /opt/homebrew/bin

        # golang
        fish_add_path /${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.home.username}/Dev/Tech/Golang/bin

        # gcloud
        fish_add_path /${if pkgs.stdenv.isDarwin then "Users" else "home"}/${config.home.username}/Dev/Tech/google-cloud-sdk/bin

        # Aliases
        # alias dev="cd $HOME/Dev/"
        # alias personaldev="cd $HOME/Dev/Personal"
        # alias paperdev="cd $HOME/Dev/Paper"
        # alias nixdir="cd ~/.config/nixpkgs"
        # alias di="devenv init"
        # alias ds="devenv shell -c $SHELL"
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
        docker_context = {
          disabled = true;
        };
      };
    };
  };
}
