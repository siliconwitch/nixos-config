{
  description = "Mist - A minimal NixOS based workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-claude.url = "github:NixOS/nixpkgs/master";
    # Pinned kernel until s2idle bug is fixed
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/e73de5be04e0eff4190a1432b946d469c794e7b4";
    # Pinned freecad until fixed upstream
    nixpkgs-pinned.url = "github:NixOS/nixpkgs/d407951447dcd00442e97087bf374aad70c04cea";
    battui.url = "github:siliconwitch/battui";
    battui.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixpkgs-claude, nixpkgs-kernel, nixpkgs-pinned, battui, ... }: {
    nixosConfigurations.mist = nixpkgs.lib.nixosSystem {
      specialArgs = { username = "raj"; inherit nixpkgs-claude nixpkgs-kernel nixpkgs-pinned; };
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
