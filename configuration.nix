# Minimal host entrypoint: hardware + modules + Home Manager wiring.
{
  inputs,
  unstable,
  old,
  ...
}:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    ./modules
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    # Handles the "Existing file would be clobbered" error.
    backupFileExtension = "zbakkk";

    users.superkat01 = import ./home.nix;

    extraSpecialArgs = {
      inherit inputs unstable old;
    };
  };

  # First-install release for stateful-data defaults (see `man configuration.nix`).
  system.stateVersion = "25.11";
}
