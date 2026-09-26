{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "brave";
  };

  xdg.mimeApps = {
    enable = true;

    defaultApplications = {
      # Web Browser (Brave)
      "text/html" = [ "brave-browser.desktop" ];
      "x-scheme-handler/http" = [ "brave-browser.desktop" ];
      "x-scheme-handler/https" = [ "brave-browser.desktop" ];
      "x-scheme-handler/about" = [ "brave-browser.desktop" ];
      "x-scheme-handler/unknown" = [ "brave-browser.desktop" ];
      "application/pdf" = [ "brave-browser.desktop" ];

      # Text Editor (Neovim)
      "text/plain" = [ "nvim.desktop" ];
      "text/x-makefile" = [ "nvim.desktop" ];
      "text/markdown" = [ "nvim.desktop" ];
      "application/json" = [ "nvim.desktop" ];

      # Image Viewer (imv)
      "image/png" = [ "imv.desktop" ];
      "image/jpeg" = [ "imv.desktop" ];
      "image/jpg" = [ "imv.desktop" ];
      "image/webp" = [ "imv.desktop" ];
      "image/gif" = [ "imv.desktop" ];
      "image/svg+xml" = [ "imv.desktop" ];

      # Media Player (mpv)
      "video/mp4" = [ "mpv.desktop" ];
      "video/mkv" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/avi" = [ "mpv.desktop" ];
      "audio/mpeg" = [ "mpv.desktop" ];
      "audio/flac" = [ "mpv.desktop" ];
      "audio/wav" = [ "mpv.desktop" ];
      "audio/ogg" = [ "mpv.desktop" ];
    };
  };
}
