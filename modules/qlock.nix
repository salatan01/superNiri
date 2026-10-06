# qLock video lockscreen (ext-session-lock for Niri).
# Package follows the repo's explicit-flake-input pattern (see parallex in
# ./packages.nix): no global overlay, pinned via flake.lock.
# Settings land in /etc/qlock/config.json; per-user overrides (if ever
# needed) go in ~/.config/qlock/config.json and win automatically.
# NOTE: lock keybind lives in ~/.config/niri/config.kdl (manual file, not
# managed here): Mod+Return spawns "qlock". Idle/sleep locking is handled
# by home/hypridle.nix (lock_cmd, on-timeout, before_sleep_cmd = qlock).
{ inputs, pkgs, ... }:
{
  imports = [ inputs.qlock.nixosModules.default ];

  services.qlock = {
    enable = true;
    package = inputs.qlock.packages.${pkgs.stdenv.hostPlatform.system}.default;
    settings = {
      videoDirectory = "~/qSets/qLock/";
      mode = "random";
      volume = 15;
      repeat = true;
      playback = 2;
    };
  };
}
