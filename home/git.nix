{ ... }:

let
  budhilaw = {
    name = "Ericsson Budhilaw";
    email = "ericsson.budhilaw@gmail.com";
    signingKey = "8A2839421B711B45";
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
      "git@gitlab.com:" = {
        insteadOf = "https://gitlab.com/";
      };
      "git@bitbucket.org:" = {
        insteadOf = "https://bitbucket.org/";
      };
    };
  };

  programs.git.userEmail = budhilaw.email;
  programs.git.userName = budhilaw.name;
  programs.git.signing.key = "8A2839421B711B45";

  programs.git.includes = [
    {
      condition = "gitdir:~/Development/Golang/";
      contents.user = budhilaw;
    }
    {
      condition = "gitdir:/Users/kai/.config/nixpkgs";
      contents.user = budhilaw;
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
