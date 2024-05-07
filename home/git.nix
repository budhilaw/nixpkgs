{ ... }:

let
  budhilaw = {
    name = "Ericsson Budhilaw";
    email = "ericsson.budhilaw@gmail.com";
    signingKey = "1935BD7070055DDC";
  };

  paper = {
    name = "Ericsson Budhilaw";
    email = "ericsson.budhilaw@paper.id";
    signingKey = "6978961D6E0EC67C";
  };
in
{
  programs.git.enable = true;

  programs.git.ignores = [
    ".DS_Store"
  ];

  programs.git.extraConfig = {
    gpg.program = "gpg";
    rerere.enable = true;
    commit.gpgSign = true;
    pull.ff = "only";
    diff.tool = "code";
    difftool.prompt = false;
    merge.tool = "code";
    url = {
      # for go mod
      # "git@github.com-paper:paper-indonesia" = {
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
      condition = "gitdir:~/Personal/";
      contents.user = budhilaw;
    }
    {
      condition = "gitdir:~/Paper/";
      contents.user = paper;
    }
    {
      condition = "gitdir:~/.config/nixpkgs/";
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
