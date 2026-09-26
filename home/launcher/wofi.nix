{ config, pkgs, ... }:

{
  programs.wofi = {
    enable = true;

    # ────────────── Settings ──────────────
    settings = {
      mode = "drun";
      show = "drun";
      width = 500;
      height = 350;
      location = "center";
      bottom = false;
      prompt = "Search Apps...";
      filter_rate = 100;
      allow_images = true;
      image_size = 24;
      gtk_dark = false;
      layer = "top";
      sensitive = false;
      allow_markup = true;
      no_actions = true;
      orientation = "vertical";
    };

    # ────────────── Style ──────────────
    style = ''
      /* General Reset */
      * {
          font-family: "JetBrains Mono Nerd Font", monospace;
          font-weight: 500;
          font-size: 14px;
      }

      /* THE FIX: Root window transparency */
      window {
          margin: 0px;
          background-color: transparent;
          border-radius: 16px;
      }

      /* Outer Box with Theme */
      #outer-box {
          margin: 0px;
          background-color: #fdf6e3;
          border: 2px solid #3159eb;
          border-radius: 16px;
      }

      /* Search Bar */
      #input {
          margin: 10px;
          padding: 10px 15px;
          border: none;
          border-radius: 10px;
          background-color: #eee8d5;
          color: #575268;
          font-weight: bold;
      }

      #input:focus {
          box-shadow: 0px 0px 4px 1px #3159eb;
          outline: none;
      }

      /* Inner Box (list container) */
      #inner-box {
          margin: 10px;
          border: none;
          background-color: transparent;
      }

      /* List Entries */
      #entry {
          padding: 10px 15px;
          margin: 0px 0px 5px 0px;
          border-radius: 10px;
          border: none;
          background-color: transparent;
          transition: all 0.2s ease;
      }

      #text {
          margin-left: 10px;
          color: #575268;
      }

      /* Selected Entry */
      #entry:selected {
          background-color: #3159eb;
          font-weight: bold;
      }

      #entry:selected #text {
          color: #fdf6e3;
      }

      #img {
          background-color: transparent;
          margin-right: 5px;
      }

      /* Hide Scrollbar */
      #scroll {
          margin: 0px;
          border: none;
      }
    '';
  };
}
