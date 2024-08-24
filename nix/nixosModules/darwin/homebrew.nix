{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  brewEnabled = config.homebrew.enable;
in
{
  environment.shellInit =
    mkIf brewEnabled # bash
      ''
        eval "$(${config.homebrew.brewPrefix}/brew shellenv)"
      '';

  system.activationScripts.preUserActivation.text =
    mkIf brewEnabled # bash
      ''
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
    CopyClip = 595191960;
    WhatsApp = 310633997;
  };

  homebrew.casks = [
    ##############
    # Development
    ##############
    "jetbrains-toolbox"

    ##############
    # Productivity
    ##############
    "1password"
    "1password-cli"
  ];

  homebrew.brews = [
    # None
  ];

}