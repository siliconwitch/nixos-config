{ pkgs, ... }:

{
  security.apparmor = {
    enable = true;
    policies."protect-sensitive" = {
      state = "enforce";
      profile = ''
        profile catchall /** flags=(attach_disconnected, mediate_deleted) {
          capability,
          network,
          file,
          mount,
          umount,
          pivot_root,
          ptrace,
          signal,
          dbus,
          unix,
          
          # Block access to specific files
          deny /home/*/.gnupg/**            rwklmx,
          deny /home/*/.password-store/**   rwklmx,
          deny /home/*/.ssh/authorized_keys rwklmx,
          deny /home/*/.ssh/config          rwklmx,
          deny /home/*/.ssh/id_rsa          rwklmx,
          deny /home/*/.ssh/id_ecdsa        rwklmx,
          deny /home/*/.ssh/id_ecdsa_sk     rwklmx,
          deny /home/*/.ssh/id_ed25519      rwklmx,
          deny /home/*/.ssh/id_ed25519_sk   rwklmx,
          deny /home/*/.ssh/id_*.pub         wklmx,

          # Profiles for allowlisted apps
          ${pkgs.git}/bin/git         px,
          ${pkgs.openssh}/bin/ssh     px,
          ${pkgs.pass}/bin/pass       px,
          ${pkgs.gnupg}/bin/gpg       px,
          ${pkgs.gnupg}/bin/gpg-agent px,
        }

        profile git ${pkgs.git}/bin/git flags=(attach_disconnected, mediate_deleted) {
          capability,
          network,
          file,
          mount,
          umount,
          pivot_root,
          ptrace,
          signal,
          dbus,
          unix,

          deny /home/*/.gnupg/**   rwklmx,
          deny /home/*/.ssh/id_*   rwklmx,
        }

        profile ssh ${pkgs.openssh}/bin/ssh flags=(attach_disconnected, mediate_deleted) {
          capability,
          network,
          file,
          mount,
          umount,
          pivot_root,
          ptrace,
          signal,
          dbus,
          unix,
          
          deny /home/*/.gnupg/**          rwklmx,
          deny /home/*/.password-store/** rwklmx,
        }

        profile pass ${pkgs.pass}/bin/pass flags=(attach_disconnected, mediate_deleted) {
          capability,
          network,
          file,
          mount,
          umount,
          pivot_root,
          ptrace,
          signal,
          dbus,
          unix,

          ${pkgs.git}/bin/git px,
        }

        profile gpg ${pkgs.gnupg}/bin/gpg flags=(attach_disconnected, mediate_deleted) {
          capability,
          network,
          file,
          mount,
          umount,
          pivot_root,
          ptrace,
          signal,
          dbus,
          unix,
        }
        
        profile gpg-agent ${pkgs.gnupg}/bin/gpg-agent flags=(attach_disconnected, mediate_deleted) {
          capability,
          network,
          file,
          mount,
          umount,
          pivot_root,
          ptrace,
          signal,
          dbus,
          unix,
        }
      '';
    };
  };
}
