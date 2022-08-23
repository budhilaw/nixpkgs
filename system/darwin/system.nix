{ ... }:
{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix.configureBuildUsers = true;

  security.pam.enableSudoTouchIdAuth = false;
}
