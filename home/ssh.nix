{ config, pkgs, lib, ... }:

let

in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Personal
      personal = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_personal";
      };

      # Paper.id
      work = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_work";
      };
    };
  };
}