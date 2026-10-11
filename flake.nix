{
  description = "SuperKat";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-25.11";

    # Lanzaboote Secure Boot module (no nixpkgs follows override to avoid toolchain breakage)
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };

    parallex.url = "github:nightkatt/parallex";
    parallex.inputs.nixpkgs.follows = "nixpkgs";

    qlock = {
      url = "github:salatan01/qLock";
      inputs.nixpkgs.follows = "nixpkgs"; # share one ffmpeg/Qt with your system
    };

    qlex = {
      url = "github:salatan01/qlex";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      nixpkgs-old,
      qlock,
      qlex,
      lanzaboote,
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
        modules = [
          lanzaboote.nixosModules.lanzaboote
          ./configuration.nix
        ];
      };
    };
}
