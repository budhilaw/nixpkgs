{ pkgs, ... }:

let
  budhilaw = {
    name = "Ericsson Budhilaw";
    email = "ericsson.budhilaw@gmail.com";
    signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYwjcDzshHuZwKxy4L+MNkYUfIN8d8CehEkvqlQiJPx";
  };

  paper = {
    name = "Ericsson Budhilaw";
    email = "ericsson.budhilaw@paper.id";
    signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOL/lqfHM8B0cF9xC9wO1rwLlDIRCqGHGmVGgS7olsf3";
  };
in
{
  programs.git.enable = true;

  programs.git.ignores = [
    ".DS_Store"
  ];

  programs.git.extraConfig = {
    gpg.format = "ssh";
    gpg.program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
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
