# Core system configuration: networking, locale, users, nix.
# (Boot lives in ./boot.nix; packages and programs in ./packages.nix.)
{ pkgs, unstable, ... }:

{
  networking.hostName = "nixos";
  # networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # networking.extraHosts = ''
  #   127.0.0.1 movieall123.xyz
  # '';

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "Asia/Dhaka";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_SG.UTF-8";
    LC_IDENTIFICATION = "en_SG.UTF-8";
    LC_MEASUREMENT = "en_SG.UTF-8";
    LC_MONETARY = "en_SG.UTF-8";
    LC_NAME = "en_SG.UTF-8";
    LC_NUMERIC = "en_SG.UTF-8";
    LC_PAPER = "en_SG.UTF-8";
    LC_TELEPHONE = "en_SG.UTF-8";
    LC_TIME = "en_SG.UTF-8";
  };

  #  services.clamav = {
  #    # This enables the freshclam updater service
  #    updater.enable = true;
  #    package = unstable.clamav;
  #    # Optional: Enable the daemon so you don't have to scan manually
  #    daemon.enable = true;
  #  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.superkat01 = {
    isNormalUser = true;
    description = "SulTan Mahmud";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List services that you want to enable:
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
}
