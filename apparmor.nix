{ pkgs, ... }:

{
  security.apparmor = {
    enable = true;
    policies."protect-sensitive" = {
      state = "complain";
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

          # Transition to specific profiles for allowlisted apps
          ${pkgs.git}/bin/git     px,
          ${pkgs.openssh}/bin/ssh px,
          ${pkgs.pass}/bin/pass   px,
          ${pkgs.gnupg}/bin/gpg2  px,

          deny /home/*/.ssh/id_rsa          rwklmx,
          deny /home/*/.ssh/id_ecdsa        rwklmx,
          deny /home/*/.ssh/id_ecdsa_sk     rwklmx,
          deny /home/*/.ssh/id_ed25519      rwklmx,
          deny /home/*/.ssh/id_ed25519_sk   rwklmx,
          deny /home/*/.ssh/config          rwklmx,
          deny /home/*/.ssh/authorized_keys rwklmx,
          deny /home/*/.gnupg/**            rwklmx,
          deny /home/*/.password-store/**   rwklmx,
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

          deny /home/*/.gnupg/** rwklmx,
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
    
          ${pkgs.gnupg}/bin/gpg2 px,
          ${pkgs.git}/bin/git    px,
        }

        profile gpg2 ${pkgs.gnupg}/bin/gpg2 flags=(attach_disconnected, mediate_deleted) {
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
