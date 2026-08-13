{
  description = "Mist - A minimal NixOS based workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    battui.url = "github:siliconwitch/battui";
    battui.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixpkgs-master, battui, ... }: {
    nixosConfigurations.mist = nixpkgs.lib.nixosSystem {
      specialArgs = { username = "raj"; inherit nixpkgs-master; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./apparmor.nix
        ./webapps.nix
        battui.nixosModules.default
      ];
    };
  };
}
