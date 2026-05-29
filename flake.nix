{
  description = "storm NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    homeManager = {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.raj = ./home.nix;
    };
  in {
    nixosConfigurations = {
      storm = nixpkgs.lib.nixosSystem {
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          homeManager
        ];
      };

      live = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./live.nix
          home-manager.nixosModules.home-manager
          homeManager
        ];
      };
    };

    packages.x86_64-linux.iso =
      self.nixosConfigurations.live.config.system.build.isoImage;
  };
}
