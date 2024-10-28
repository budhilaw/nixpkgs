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
    "gromgit/homebrew-fuse"
  ];

  homebrew.masApps = {
    Slack = 803453959;
    CopyClip = 595191960;
    WhatsApp = 310633997;
  };

  homebrew.casks = [
    ##############
    # Tech
    ##############
    "iterm2"
    "jetbrains-toolbox"
    "pritunl"

    ##############
    # Productivity
    ##############
    "logi-options+"
    "firefox"
    "google-chrome"
    "macfuse"
    "mounty"
    
    ##############
    # Study
    ##############
    "publish-or-perish"
    "calibre"

    ##############
    # Misc
    ##############
    "1password"
    "1password-cli"
    "cloudflare-warp"
  ];

  homebrew.brews = [
    ##############
    # Productivity
    ##############
    "ntfs-3g-mac"
  ];

}
