# Noctalia declarative config via standard nixpkgs (no external flake module).
# Source of truth: ./assets/noctalia-settings.toml (snapshotted from
# ~/.local/state/noctalia/settings.toml). Reading it via
# builtins.fromTOML avoids hand-formatting quoted keys
# ("lockscreen-login-box@HDMI-A-3") and float precision.
# NOTE: deviates from the draft `pkgs.unstable.noctalia` — this repo
# passes `unstable` via specialArgs/extraSpecialArgs (see flake.nix and
# configuration.nix), so the correct reference is `unstable.noctalia`.
# Package co-located here (removed from modules/packages.nix).
{ pkgs, unstable, ... }:

let
  tomlFormat = pkgs.formats.toml { };
in
{
  # Use unstable noctalia as requested
  home.packages = [ unstable.noctalia ];

  # programs.qlex defaults extraPackages to [ pkgs.noctalia pkgs.awww ]
  # (stable 5.0.1), which collides with unstable.noctalia (5.2.0) in
  # buildEnv (`bin/.noctalia-wrapped` conflict). Pin qlex's companion set
  # to the same unstable noctalia so exactly one noctalia lands in the
  # user profile. awww stays on stable pkgs.
  programs.qlex.extraPackages = [
    unstable.noctalia
    pkgs.awww
  ];

  xdg.configFile."noctalia/config.toml".source = tomlFormat.generate "noctalia-config.toml" (
    builtins.fromTOML (builtins.readFile ./assets/noctalia-settings.toml)
  );
}
