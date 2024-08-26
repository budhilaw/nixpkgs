{ pkgs, ... }:

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
      "git@github.com-paper:" = {
        insteadOf = "https://github.com/";
      };
      "git@github.com:" = {
        insteadOf = "https://github.com/";
      };
      # "git@github.com-paper:paper-indonesia" = {
      #   insteadOf = "https://github.com/paper-indonesia/";
      # };
    };
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/Dev/Personal/";
      contents.user = budhilaw;
      contents.core = {
        sshCommand = "ssh -i ~/.ssh/id_ed25519_personal";
      };
    }
    {
      condition = "gitdir:~/Dev/Paper/";
      contents.user = paper;
      contents.core = {
        sshCommand = "ssh -i ~/.ssh/id_ed25519_work";
      };
    }
    {
      condition = "gitdir:~/.config/nixverse/";
      contents.user = budhilaw;
      contents.core = {
        sshCommand = "ssh -i ~/.ssh/id_ed25519_personal";
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

  home.packages = [ pkgs.git-filter-repo ];
}
