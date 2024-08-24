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
        user = "git";
        identityFile = "~/.ssh/id_ed25519_personal";
      };

      # Paper.id
      "github.com-paper" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_work";
      };
    };
    extraConfig = ''
      UseKeychain yes
    '';
  };
}