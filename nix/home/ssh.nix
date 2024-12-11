{ config, pkgs, lib, ... }:

let

in
{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      # Personal
      "github.com" = {
        hostname = "github.com";
        user = "budhilaw";
        identityFile = "~/.ssh/id_ed25519_personal";
      };

      # Paper.id
      "github.com-paper" = {
        hostname = "github.com";
        user = "ebudhilaw";
        identityFile = "~/.ssh/id_ed25519_work";
      };
    };
    extraConfig = ''
        UseKeychain yes
        IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    '';
  };
}