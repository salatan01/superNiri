{ config, pkgs, inputs, old, ... }:

{
  # 1. Enable Niri WM globally
  programs.niri.enable = true;
  # programs.skwd-wall.enable = true;


  # 3. Global System Packages
  environment.systemPackages = with pkgs; [
    dms-shell old.swww
 dgop   wayland-utils
 brightnessctl
 inputs.parallex.packages.${pkgs.system}.default
 
quickshell  ];

  # 4. Global Wayland Portals & Environment
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
} 
