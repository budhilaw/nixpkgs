{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf;
  brewEnabled = config.homebrew.enable;
in
{
  environment.shellInit = mkIf brewEnabled ''
    eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
  '';

  system.activationScripts.preUserActivation.text = mkIf brewEnabled ''
    if [ ! -f ${config.homebrew.brewPrefix}/brew ]; then
      ${pkgs.bash}/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  '';


  homebrew.enable = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;

  homebrew.taps = [
    # "homebrew/cask"
    # "homebrew/cask-drivers"
    # "homebrew/cask-fonts"
    # "homebrew/cask-versions"
    # "homebrew/core"
    "homebrew/services"
    # "shivammathur/php"
    # "nrlquaker/createzap"
  ];

  homebrew.masApps = {
    Slack = 803453959;
  };

  homebrew.casks = [
    ##############
    # Misc
    ##############
    "raycast"
    "bitwarden"
    "microsoft-edge"
    "shottr"
    
    ##############
    # Development
    ##############
    "jetbrains-toolbox"
    "visual-studio-code"

    ##############
    # Productivity
    ##############
    # "iterm2"
    "obs"
    "notion"
    "telegram"
    "appcleaner"
    "logi-options-plus"
    "pritunl"
  ];

  homebrew.brews = [
    "rabbitmq"
    "helm"
    # "shivammathur/php/php"
    # "shivammathur/php/php@7.1"
  ];
}
