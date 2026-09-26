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
  # Standalone programs.
  programs.firefox.enable = true;
  programs.zsh.enable = true;
  programs.dconf.enable = true;

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
    # opencode
    exiftool
    age
    # motrix
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
    neovim
    yazi
    tree
    lohit-fonts.bengali
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
    old.swww
    wayland-utils
    brightnessctl
    playerctl
    inputs.parallex.packages.${pkgs.stdenv.hostPlatform.system}.default
    bibata-cursors
    quickshell
  ];
}
