{
  description = "Mist - A minimal NixOS based workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations.mist = nixpkgs.lib.nixosSystem {
      specialArgs = { username = "raj"; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./apparmor.nix
        ./webapps.nix
      ];
    };
  };
}
