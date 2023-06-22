{ pkgs, ... }:
{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # services.mysql.enable = true;
  # services.mysql.package = pkgs.mariadb;
}