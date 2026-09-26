# Desktop foundation: pure Wayland + ly, audio, portals, fonts, theme integration.
{ pkgs, ... }:

{
  # Pure Wayland (X.Org daemon disabled; XWayland runs on demand).
  services.xserver.enable = false;
  services.displayManager.ly.enable = true;

  # XKB configuration (read by systemd-localed and Wayland compositors).
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Desktop portals.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  # GTK/Qt/QML icon & theme integration (for Noctalia via Quickshell).
  # (programs.dconf lives in ./packages.nix alongside the other programs.)
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  services.flatpak.enable = true;
  services.cloudflare-warp.enable = true;

  #################------------------Fonts ----------------#########################

  fonts.packages = with pkgs; [
    ubuntu-sans
    ubuntu-sans-mono
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    lohit-fonts.bengali
  ];

  # This ensures the system picks ubuntu as default fonts
  fonts.fontconfig = {
    defaultFonts = {
      sansSerif = [ "Ubuntu Sans" ];
      monospace = [ "Ubuntu Sans Mono" ];
    };
  };

  # Wayland environment overrides.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
