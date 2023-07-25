{ pkgs, ... }:
{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Set DNS to use dnscrypt
  networking.dns = [
    "127.0.0.1"
    "192.168.18.1"
    "1.1.1.1"
    "1.0.0.1"
  ];
}