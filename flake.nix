{
  description = "Mist - A minimal NixOS based workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-claude.url = "github:NixOS/nixpkgs/master";
    # Last revision with linux 7.0 (EOL'd upstream); 7.1.x hangs s2idle on this machine
    nixpkgs-kernel.url = "github:NixOS/nixpkgs/e73de5be04e0eff4190a1432b946d469c794e7b4";
    # Temporary pins: freecad (gdalMinimal broken, fixed in nixpkgs PR #540826)
    # and kicad (transient Hydra dep failure, uncached); drop once fixed builds
    # reach nixos-unstable
    nixpkgs-pinned.url = "github:NixOS/nixpkgs/d407951447dcd00442e97087bf374aad70c04cea";
  };

  outputs = { nixpkgs, nixpkgs-claude, nixpkgs-kernel, nixpkgs-pinned, ... }: {
    nixosConfigurations.mist = nixpkgs.lib.nixosSystem {
      specialArgs = { username = "raj"; inherit nixpkgs-claude nixpkgs-kernel nixpkgs-pinned; };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        ./apparmor.nix
        ./webapps.nix
      ];
    };
  };
}
