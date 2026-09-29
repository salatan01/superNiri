{ config, pkgs, ... }:

{
  # Ensure the power management tool is available
  home.packages = [ pkgs.wlopm ];

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "noctalia msg session lock";
        before_sleep_cmd = "loginctl lock-session";
        # Universal wake command
        after_sleep_cmd = "${pkgs.wlopm}/bin/wlopm --on *";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          # '--off *' targets all monitors universally
          on-timeout = "${pkgs.wlopm}/bin/wlopm --off *";
          on-resume = "${pkgs.wlopm}/bin/wlopm --on *";
        }
      ];
    };
  };
}
