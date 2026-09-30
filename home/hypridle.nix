{ config, pkgs, ... }:

let
  # Fallback to pure string if qlock is installed via another flake/module,
  # or replace 'qlockCmd' with "${pkgs.qlock}/bin/qlock" if it's in nixpkgs/inputs.
  qlockCmd = "pidof qlock || qlock";
in
{
  home.packages = [ pkgs.wlopm ];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Executed when 'loginctl lock-session' is triggered
        lock_cmd = qlockCmd;

        # Triggers systemd lock session BEFORE sleep hook fires
        before_sleep_cmd = "loginctl lock-session";

        # Ensures displays turn back on immediately after wake
        after_sleep_cmd = "${pkgs.wlopm}/bin/wlopm --on *";
      };

      listener = [
        # 1. Lock screen on idle (100 seconds)
        {
          timeout = 100;
          on-timeout = "loginctl lock-session";
        }
        # 2. Turn off displays on deeper idle (330 seconds)
        # {
        #   timeout = 30;
        #   # Force lock session AND kill display power
        #   on-timeout = "loginctl lock-session; ${pkgs.wlopm}/bin/wlopm --off *";
        #   on-resume = "${pkgs.wlopm}/bin/wlopm --on *";
        # }
      ];
    };
  };
}
