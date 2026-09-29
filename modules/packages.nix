# All system-level packages and standalone programs in one place.
# Subsystem-coupled options (programs.niri, qt, services) stay with their
# modules; everything installed for general use lives here.
{
  pkgs,
  inputs,
  unstable,
  old,
  ...
}:

{
  # Standalone programs (imported from ~/Desktop/niriDE/modules/pkgs.nix).
  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.dconf.enable = true;

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Common libraries that unpatched binaries usually look for
    stdenv.cc.cc
    zlib
    glib
    # libX11
  ];
  programs.neovim.enable = true;
  programs.nano.enable = false;
  programs.partition-manager.enable = true;
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true; # Optimized for flakes
  # programs.nh.enable = true;

  documentation.man.enable = true;
  # documentation.dev.enable = true; # Often where 'as' docs hide

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # ── Core CLI / TUI (stable) ──
    gh
    exiftool
    age
    realesrgan-ncnn-vulkan
    realcugan-ncnn-vulkan
    cava
    duf
    nautilus
    ffmpeg
    btop
    ripgrep
    fd
    sd
    git
    wget
    yazi
    tree
    wl-clipboard
    # unstable.catgirldownloader
    gparted

    # ── Unstable channel ──
    unstable.opencode
    unstable.ani-cli
    unstable.yt-dlp

    # ── Old channel ──
    # (no channel-pinned packages currently)

    # ── Desktop: icon themes (Noctalia / GTK file chooser) ──
    papirus-icon-theme
    hicolor-icon-theme

    # ── Niri / Wayland ──
    imv
    matugen
    unstable.noctalia
    # old.swww
    awww
    wayland-utils
    brightnessctl
    playerctl
    inputs.parallex.packages.${pkgs.stdenv.hostPlatform.system}.default
    bibata-cursors
    quickshell

    # ── Imported from ~/Desktop/niriDE/modules/pkgs.nix ──

    # Web & Internet
    # brave
    android-tools
    # chromium
    # motrix
    # vesktop

    # Productivity & Writing
    kdePackages.ghostwriter
    # zed-editor
    # obsidian

    # Media & Audio
    # kdePackages.qtmultimedia
    # mpd
    # mpv
    # obs-studio
    # spotify

    # Gaming
    # steam-run

    # Core utilities & modern Unix (HM-managed fzf/zoxide/starship/delta omitted)
    bat
    tealdeer
    fastfetch
    file
    grex
    tmux

    # Development & editors
    gcc
    lazygit
    gnumake
    # nodejs
    tree-sitter

    # NixOS tools
    nix-output-monitor
    nix-search-cli
    nvd
    statix

    # System & filesystem
    bubblewrap
    dosfstools
    mtools
    unzip
    zip

    # Media processing
    # chafa
    # imagemagick
    binwalk

    # LSP & formatters (unstable)
    # unstable.clang-tools
    # unstable.rust-analyzer
    # qt6.qtdeclarative # provides qmlls
    # unstable.pyright
    unstable.alejandra
    unstable.nixd
    unstable.nixfmt
    # unstable.marksman
    # unstable.shellcheck
    # unstable.shfmt

    unstable.stretchly

    # ── Imported from niriDE: wm/display/audio/steam ──
    # (deduped: wl-clipboard, brightnessctl, playerctl, papirus,
    #  pavucontrol, xwayland-satellite, wlsunset, polkit_gnome and mpv
    #  already present above or in this section — listed once)

    # WM session essentials (wm.nix)
    polkit_gnome
    xwayland-satellite # rootless XWayland for Niri
    xdg-user-dirs # ~/Documents ~/Downloads etc.
    librsvg # SVG loader for gdk-pixbuf — prevents GTK SVG crashes
    # wlsunset # used by evelt/nightlt/nolt zsh aliases
    gtk4

    # Audio utilities (audio.nix)
    pavucontrol # standard GTK volume control
    qpwgraph # visual PipeWire routing (like Helvum)
    easyeffects # EQ, noise reduction, compression

    # Desktop integration (display.nix)
    libnotify # notify-send for scripts
    adwaita-icon-theme # fallback so GTK apps render icons

    # Gaming companions (steam.nix; steam-run already above)
    # protonup-qt # GE-Proton installer GUI
    # mangohud # in-game resource overlay
  ];
}
