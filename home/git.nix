{ ... }:

let
  budhilaw = {
    name = "Ericsson Budhilaw";
    email = "ericsson.budhilaw@gmail.com";
    signingKey = "E5F57D91920F01D7";
  };

  paper = {
    name = "Ericsson Budhilaw";
    email = "ericsson.budhilaw@paper.id";
    signingKey = "03C696C708A2A369";
  };
in
{
  programs.git.enable = true;

  programs.git.ignores = [
    ".DS_Store"
  ];

  programs.git.extraConfig = {
    # gpg.program = "gpg";
    rerere.enable = true;
    commit.gpgSign = true;
    pull.ff = "only";
    diff.tool = "code";
    difftool.prompt = false;
    merge.tool = "code";
    url = {
      # "git@github.com-paper:paper-indonesia" = {
      #   insteadOf = "https://github.com/paper-indonesia";
      # };
      # "git@github.com:paper-indonesia" = {
      #   insteadOf = "https://github.com/paper-indonesia";
      # };
      "git@gitlab.com:" = {
        insteadOf = "https://gitlab.com/";
      };
      "git@github.com:" = {
        insteadOf = "https://github.com/";
      };
    };
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/Dev/Personal/";
      contents.user = budhilaw;
      contents.commit = {
        gpgSign = true;
      };
    }
    {
      condition = "gitdir:~/Dev/Paper/";
      contents.user = paper;
      contents.commit = {
        gpgSign = true;
      };
    }
    {
      condition = "gitdir:~/.config/nixpkgs/";
      contents.user = budhilaw;
      contents.commit = {
        gpgSign = true;
      };
    }
  ];

  ### git tools
  ## github cli
  programs.gh.enable = true;
  programs.gh.settings.git_protocol = "ssh";
  programs.gh.settings.aliases = {
    co = "pr checkout";
    pv = "pr view";
  };
}
