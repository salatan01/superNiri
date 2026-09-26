{ config, pkgs, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      # --- Dynamic Powerline Segment Transitions ---
      format = builtins.concatStringsSep "" [
        "[](fg:purple)" # Left pill cap matches NightKat background
        "$username"
        "[](bg:yellow fg:purple)" # Transition: purple -> yellow
        "$directory"
        "[](fg:yellow bg:green)" # Transition: yellow -> green
        "$git_branch"
        "$git_status"
        "[](fg:green bg:cyan)" # Transition: green -> cyan
        "$nix_shell"
        "$c"
        "$rust"
        "$golang"
        "$nodejs"
        "$php"
        "$java"
        "$kotlin"
        "$haskell"
        "$python"
        "[](fg:cyan bg:blue)" # Transition: cyan -> blue
        "$docker_context"
        "[ ](fg:blue)" # Right end cap
        "$line_break"
        "$character"
      ];

      # --- Username (Pitch Black Text on Dynamic Purple Segment) ---
      username = {
        show_always = true;
        style_user = "bg:purple fg:black";
        style_root = "bg:purple fg:black";
        format = "[ NightKat ]($style)";
      };

      # --- Directory (Pitch Black Text) ---
      directory = {
        style = "fg:black bg:yellow";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = "󰝚 ";
          "Pictures" = " ";
          "Developer" = "󰲋 ";
        };
      };

      # --- Git Configuration (Pitch Black Text & Icons) ---
      git_branch = {
        symbol = "";
        style = "bg:green";
        format = "[[ $symbol $branch ](fg:black bg:green)]($style)";
      };

      git_status = {
        style = "bg:green";
        format = "[[($all_status$ahead_behind )](fg:black bg:green)]($style)";
      };

      nix_shell = {
        disabled = false;
        symbol = " ";
        style = "bg:cyan";
        format = "[[ $symbol ](fg:black bg:cyan)]($style)";
      };

      # --- Language Modules (Pitch Black Text & Icons) ---
      c = {
        symbol = " ";
        style = "bg:cyan";
        format = "[[ $symbol( $version) ](fg:black bg:cyan)]($style)";
      };
      rust = {
        symbol = "";
        style = "bg:cyan";
        format = "[[ $symbol( $version) ](fg:black bg:cyan)]($style)";
      };
      golang = {
        symbol = "";
        style = "bg:cyan";
        format = "[[ $symbol( $version) ](fg:black bg:cyan)]($style)";
      };
      nodejs = {
        symbol = "";
        style = "bg:cyan";
        format = "[[ $symbol( $version) ](fg:black bg:cyan)]($style)";
      };
      php = {
        symbol = "";
        style = "bg:cyan";
        format = "[[ $symbol( $version) ](fg:black bg:cyan)]($style)";
      };
      java = {
        symbol = " ";
        style = "bg:cyan";
        format = "[[ $symbol( $version) ](fg:black bg:cyan)]($style)";
      };
      kotlin = {
        symbol = "";
        style = "bg:cyan";
        format = "[[ $symbol( $version) ](fg:black bg:cyan)]($style)";
      };
      haskell = {
        symbol = "";
        style = "bg:cyan";
        format = "[[ $symbol( $version) ](fg:black bg:cyan)]($style)";
      };
      python = {
        symbol = "";
        style = "bg:cyan";
        format = "[[ $symbol( $version) ](fg:black bg:cyan)]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:blue";
        format = "[[ $symbol( $context) ](fg:black bg:blue)]($style)";
      };

      line_break.disabled = false;

      character = {
        disabled = false;
        success_symbol = "[](bold fg:green)";
        error_symbol = "[](bold fg:red)";
        vimcmd_symbol = "[](bold fg:green)";
        vimcmd_replace_one_symbol = "[](bold fg:purple)";
        vimcmd_replace_symbol = "[](bold fg:purple)";
        vimcmd_visual_symbol = "[](bold fg:cyan)";
      };
    };
  };
}
