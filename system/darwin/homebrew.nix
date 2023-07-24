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
    "google-chrome"
    "shottr"
    
    ##############
    # Development
    ##############
    "jetbrains-toolbox"
    "visual-studio-code"

    ##############
    # Productivity
    ##############
    "obs"
    "notion"
    "telegram"
    "appcleaner"
    "logi-options-plus"
    "pritunl"
    "keka"
  ];

  homebrew.brews = [
    # ...
  ];
}
