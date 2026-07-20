{
  description = "Mist - A minimal NixOS based workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-claude.url = "github:NixOS/nixpkgs/master";
    # Pinned freecad until fixed upstream
    nixpkgs-pinned.url = "github:NixOS/nixpkgs/d407951447dcd00442e97087bf374aad70c04cea";
    battui.url = "github:siliconwitch/battui";
    battui.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixpkgs-claude, nixpkgs-pinned, battui, ... }: {
    nixosConfigurations.mist = nixpkgs.lib.nixosSystem {
      specialArgs = { username = "raj"; inherit nixpkgs-claude nixpkgs-pinned; };
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
