{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      # background-opacity = 0.3;
      background-blur-radius = 20;
      # ────────────── Fonts ──────────────
      font-family = "JetBrainsMono Nerd Font";
      font-size = 14;
      font-feature = [
        "calt"
        "liga"
      ];

      # ────────────── Appearance ──────────────
      # theme = "Catppuccin Mocha";
      # theme = "Night Owl";
      theme = "Gruvbox Material";
      # theme = "Solarized Osaka Night";
      # theme = "iTerm2 Solarized Light";
      # theme = "TokyoNight Day";
      # theme = "Everforest Dark Hard";
      # theme = "Rose Pine Moon";
      # This removes the title bar/tab bar for that clean Niri look
      window-decoration = false;

      # Optional: Makes the window slightly transparent to match Hyprlock vibes
      #     window-background-opacity = 0.9;

      # ────────────── Behavior ──────────────
      mouse-hide-while-typing = true;
      scrollback-limit = 10000;

      # Since you're on Niri, you might want this to handle window resizing smoothly
      window-step-resize = true;
    };
  };
}
