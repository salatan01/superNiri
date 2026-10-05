# qlex wallpaper picker (quickshell UI + Rust daemon).
# Package + Home Manager module follow the repo's explicit-flake-input pattern
# (see parallex in ./packages.nix and qlock in ../modules/qlock.nix): no global
# overlay, pinned via flake.lock.
# NOTE: niri owns startup and keybinds — ~/.config/niri/config.kdl is a manual
# file, not managed here. You need these two lines (backend first):
#   spawn-at-startup "awww-daemon"
#   spawn-at-startup "qlexd"
# …and a picker bind, e.g. replacing the parallex one:
#   Mod+W { spawn "qlex" "ui"; }
{ inputs, pkgs, ... }:
{
  imports = [ inputs.qlex.homeManagerModules.default ];

  programs.qlex = {
    enable = true;
    package = inputs.qlex.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # ── Full qlex.toml surface ──────────────────────────────────────────
    # Written to ~/.config/qlex/qlex.toml. Every key is optional in qlex
    # itself (invalid files fall back to defaults with a warning); they are
    # spelled out here so this file is the single source of truth.
    settings = {
      wallpaper_dirs = [ "~/qSets/qLex/static" ];
      recursive = true;
      extensions = [
        "jpg"
        "jpeg"
        "png"
        "webp"
      ];
      thumb_width = 480;
      thumb_height = 300;
      # Worker threads for thumbnail generation; 0 = auto.
      thumb_workers = 0;

      theme = {
        # Wallpaper backend: "awww" ("swww" still accepted, deprecated).
        wallpaper_backend = "awww";
        # Theming provider: "noctalia" | "custom" | "none".
        provider = "noctalia";
        # For provider = "custom": matugen scheme + mode + shell template
        # (custom_command carries %path% %scheme% %mode%; unset = None).
        scheme = "scheme-tonal-spot";
        mode = "dark";
        # For provider = "noctalia".
        noctalia_scheme = "m3-tonal-spot";
        noctalia_palette = "qlex";
        # awww transition for applies.
        transition = "wipe";
        transition_angle = 30;
        transition_duration = 1.0;
      };
    };
  };
}
