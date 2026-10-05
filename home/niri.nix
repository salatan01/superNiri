# Niri compositor config — declarative file snapshot (KDL has no
# pkgs.formats equivalent worth using; verbatim file is the honest mapping).
# Source of truth: ./assets/niri-config.kdl (snapshotted from
# ~/.config/niri/config.kdl, then cleaned of dead DMS includes and binds
# to uninstalled apps). Validate edits with:
#   niri validate --config ./assets/niri-config.kdl   (needs a sibling
#   noctalia.kdl for the relative include — see below)
# NOTE: only config.kdl is store-managed. `noctalia.kdl` is generated at
# runtime by Noctalia's theme engine and must stay writable in
# ~/.config/niri/, so never manage the whole directory — the relative
# `include "noctalia.kdl"` keeps resolving against the live dir.
{ ... }:
{
  xdg.configFile."niri/config.kdl".source = ./assets/niri-config.kdl;
}
