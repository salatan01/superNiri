{
  description = "SuperKat";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-25.11";

    parallex.url = "github:nightkatt/parallex";
    parallex.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-old,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      old = import nixpkgs-old {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs unstable old;
        };
        modules = [ ./configuration.nix ];
      };
    };
}
