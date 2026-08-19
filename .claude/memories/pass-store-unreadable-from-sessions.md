# The password store is unreadable from sessions

Permission denied on ~/.password-store (and ~/.gnupg, ssh keys) is Raj's own AppArmor catchall in apparmor.nix, NOT the harness sandbox; use pass/git (allowlisted) instead of find/cat.

Any "Permission denied" on `~/.password-store/**`, `~/.gnupg/**`, or ssh key
files (from my session OR from Raj's own terminal) is the `catchall` AppArmor
profile in `apparmor.nix`: it attaches to `/**` (every binary, interactive
shells included) and denies those paths, with only pass/git/gpg/gpg-agent/ssh
px-transitioning to permissive profiles. Diagnosed 2026-07-31 after wrongly
blaming the harness sandbox first.

**Why:** deliberate defense so only the named tools touch secrets. It is
subtle to recognize because perms look clean (755 raj:users), `stat`/`getfacl`
succeed (AppArmor mediates open, not stat), `ls` of the store ROOT lists names
(`/**` matches contents, not the dir itself), and `git` works while `cat`
fails. `dangerouslyDisableSandbox` changes nothing (it is not the sandbox).

**How to apply:** never fight it and don't propose loosening it. Route store
work through allowlisted binaries: `git -C ~/.password-store ls-files` to
enumerate entries (all tracked; used in place of `find`, which cannot descend
subdirs), `pass show`/`pass insert -m -f` for content. Batch-edit loops built
this way work; print entry names only, never values. Raj must run them in his
own terminal anyway: gpg in-session dies at pinentry (no interactive prompt).
Store is git-backed; `pass git reset --hard <hash>` rolls back. 119 entries
as of 2026-07-31, clean at 2474359 before the prefix-strip batch edit.
