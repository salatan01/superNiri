{
  description = "SuperKat";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-pinned.url = "github:nixos/nixpkgs/e576e3c9cf9bad747afcddd9e34f51d18c855b4e";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-25.11";

    parallex.url = "github:nightkatt/parallex";
    parallex.inputs.nixpkgs.follows = "nixpkgs";

    skwd-wall.url = "github:liixini/skwd-wall";
skwd-wall.inputs.nixpkgs.follows = "nixpkgs";




  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      # nixpkgs-pinned,
      nixpkgs-old,
      home-manager,
      parallex,
      skwd-wall,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      # pinned = import nixpkgs-pinned {
      #   inherit system;
      #   config.allowUnfree = true;
      # };
      old = import nixpkgs-old {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit
            inputs
            unstable
            old
            ;
        };
        modules = [
          ./configuration.nix
skwd-wall.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # --- THE FIX ---
            # This handles the "Existing file would be clobbered" error
            home-manager.backupFileExtension = "zbakkk";
            # ---------------

            home-manager.users.superkat01 = import ./home.nix;

            home-manager.extraSpecialArgs = {
              inherit
                inputs
                unstable
                # pinned
                old
                ;
            };
          }
        ];
      };
    };
}
