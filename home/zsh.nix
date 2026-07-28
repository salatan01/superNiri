{ config, pkgs, ... }:
{
  # ────────────── Core Zsh Setup ──────────────
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      share = true;
    };

    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -la --icons --group-directories-first";

      cpwd = "pwd | wl-copy";
      grep = "grep --color=auto";
      nos-rebld = "sudo nixos-rebuild switch";
      nos-rolbk = "sudo nixos-rebuild switch --rollback";
      nos-upg = "sudo nixos-rebuild switch --upgrade";
      ff = "fastfetch";
      whgen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      nos-gc = "sudo nix-collect-garbage -d && sudo nix-store --optimise";
      ns = "nix-search";
      tst = "nix-shell -p";
      xft = "exiftool";
      nv = "nvim";
      zd = "zeditor";
      vs = "code";
      gem = "gemini";
      gin = "git init";
      gcm = "git commit";
      gad = "git add";
      glg = "git log --oneline";
      grl = "git reflog";
      grs = "git reset";
      gst = "git status";
      gco = "git checkout";
      grt = "git restore";
      gcl = "git clone";
      gph = "git push";
      gdf = "git diff";
      gpl = "git pull";
      evelt = "pkill wlsunset 2>/dev/null; wlsunset -t 4250 & disown";
      nightlt = "pkill wlsunset 2>/dev/null; wlsunset -t 3000 & disown";
      nolt = "pkill wlsunset 2>/dev/null; true";

      # Nix Command Aliases
      nfi = "nix flake init";
      nfu = "nix flake update";
      nfc = "nix flake check";
      nfs = "nix flake show";
      nrn = "nix run";
      nsh = "nix shell";
      ndv = "nix develop";
      nbl = "nix build";
      nlg = "nix log check";

      # Warp-cli Aliases
      warpcnt = "warp-cli connect";
      warpdcnt = "warp-cli disconnect";
      warpregnew = "warp-cli registration new";
      warpsts = "warp-cli status";
    };

    # ────────────── Functions & Raw Zsh Config ──────────────
    initContent = ''
            export LS_COLORS=$LS_COLORS:'di=01;33:'

      # Optimized Global Directory Jump
      jd() {
        local dir
        dir=$(fd --type d --base-directory ~ | fzf --height 40% --reverse --header="Jump to Directory") \
          && cd ~/"$dir"
      }

      # Optimized Global File Edit
      jf() {
        local file
        file=$(fd --type f --base-directory ~ | fzf --height 60% --reverse \
              --header="Edit File with Nvim" \
              --preview 'bat --line-range=:50 --color=always ~/{}') \
          && nvim ~/"$file"
      }

    '';
  };

  # ────────────── The Ultimate Dev Integrations ──────────────
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
