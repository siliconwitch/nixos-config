{
  description = "NixOS configuration";

  inputs = {
    # Track the latest packages; generations are the rollback net.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }: {
    # storm — the laptop. hostPlatform comes from hardware-configuration.nix.
    nixosConfigurations.storm = nixpkgs.lib.nixosSystem {
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
  };
}
