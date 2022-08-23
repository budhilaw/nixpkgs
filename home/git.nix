{ config, pkgs, ... }:

{
  # Git
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.git.enable
  # Aliases config in ./configs/git-aliases.nix
  programs.git.enable = true;

  programs.git.ignores = [
    ".DS_Store"
  ];

  programs.git.extraConfig = {
    # gpg.program = "gpg";
    rerere.enable = true;
    # commit.gpgSign = true;
    pull.ff = "only";
    diff.tool = "vimdiff";
    difftool.prompt = false;
    merge.tool = "vimdiff";
    url = {
      "git@gitlab.com:" = {
        insteadOf = "https://gitlab.com/";
      };
      "git@github.com:" = {
        insteadOf = "https://github.com/";
      };
    };
  };

  programs.git.userEmail = config.home.user-info.email;
  programs.git.userName = config.home.user-info.fullName;
  programs.git.signing.key = "8A2839421B711B45";

  ### git tools
  ## github cli
  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";
}