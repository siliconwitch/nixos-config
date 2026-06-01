{
  description = "NixOS configuration";

  inputs = {
    # Track the latest packages; generations are the rollback net.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      # Test VM (configuration.nix + VM boot/hardware).
      vm = nixpkgs.lib.nixosSystem {
        modules = [ ./vm.nix ];
      };

      # Live ISO for testing on real hardware.
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./iso.nix ];
      };
    };

    packages.x86_64-linux.iso =
      self.nixosConfigurations.iso.config.system.build.isoImage;
  };
}
