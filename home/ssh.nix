{ config, pkgs, lib, ... }:

let

in
{
  programs.ssh = {
    enable = true;
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
        user = "budhilawpaper";
        identityFile = "~/.ssh/id_ed25519_work";
      };
    };
  };
}