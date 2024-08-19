{
  pkgs,
  config,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    dnscrypt-proxy2
  ];

  # dnscrypt-proxy
  launchd.daemons.dnscrypt-proxy = {
    path = [ config.environment.systemPath ];
    serviceConfig.RunAtLoad = true;
    serviceConfig.KeepAlive = true;
    serviceConfig.StandardOutPath = "/tmp/launchd-dnscrypt.log";
    serviceConfig.StandardErrorPath = "/tmp/launchd-dnscrypt.error";
    serviceConfig.ProgramArguments = [
      "${pkgs.dnscrypt-proxy2}/bin/dnscrypt-proxy"
      "-config"
      (lib.trivial.pipe ./dnscrypt-proxy.toml [
        builtins.readFile
        (pkgs.writeText "dnscrypt-proxy.toml")
        toString
      ])
    ];
  };
}
