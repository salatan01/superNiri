# Niri window manager.
# Packages, portals, and Wayland env vars live in ./packages.nix and
# ./desktop.nix respectively; this module only enables the compositor.
{ ... }:

{
  programs.niri.enable = true;
}
