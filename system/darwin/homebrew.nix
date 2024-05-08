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
    "homebrew/services"
  ];

  homebrew.masApps = {
    Slack = 803453959;
    Dropover = 1355679052;
    CopyClip = 595191960;
  };

  homebrew.casks = [
    ##############
    # Misc
    ##############
    "raycast"
    "bitwarden"
    "shottr"
    "iina"
    "warp"
    "hiddenbar"
    "iterm2"
    
    ##############
    # Development
    ##############
    "jetbrains-toolbox"
    "visual-studio-code"
    "orbstack"
    "postman"
    "sequel-ace"

    ##############
    # Productivity
    ##############
    "obs"
    "telegram"
    "appcleaner"
    "logi-options-plus"
    "pritunl"
    "keka"
    "calibre"
    "arc"
    "publish-or-perish"
    "imageoptim"
  ];

  homebrew.brews = [
    ##############
    # Development
    ##############
    "mockery"
    "golang-migrate"
    "p7zip"
    "unar"
    "plantuml"
    "sonar-scanner"
    "ffmpeg"
  ];
}
