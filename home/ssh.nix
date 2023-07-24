{ ... }:

{

  programs.ssh.matchBlocks = {
    "work.github.com" = {
      user = "git";
      IdentityFile = "~/.ssh/id_ed25519_work";
      hostname = "github.com"
    };
  };

}