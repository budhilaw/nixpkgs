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
      "github.com:paper-indonesia" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_work";
      };
    };
  };
}