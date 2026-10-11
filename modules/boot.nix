# Boot: Lanzaboote (Secure Boot) + Plymouth splash + silent boot.
# Imported from ~/Desktop/niriDE/modules/boot.nix.
{ lib, ... }:

{
  boot = {
    loader = {
      # Force disable standard systemd-boot to delegate bootloader signing to Lanzaboote
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
      timeout = 0; # Hold space to make the boot menu appear!
    };

    # Lanzaboote Secure Boot configuration
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # Splash screen
    plymouth.enable = true;

    # Silent boot
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];

    # Hide the "Starting version 25x..." text
    consoleLogLevel = 0;
    initrd.verbose = false;
  };
}
