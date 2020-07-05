# ghcide setup (tested on fresh Ubuntu 20.04 install)

This uses [codium](https://vscodium.com/) mainly because it's exactly like vscode but conveniently has a binary named `codium` rather than `code` meaning it won't mess with your current `code` binary.

You can install it with:

``` sh
cd ~/path/to/smurf/nix/ghcide-setup
sh nix_install.sh # note sudo might be required to install curl if you don't have it already
```

If you encounter an error like this:


``` sh
cody@cody-VirtualBox:~/smurf/nix/ghcide-setup$ sh nix_install.sh 
'home.nix' -> '/home/cody/.config/nixpkgs/home.nix' (backup: '/home/cody/.config/nixpkgs/home.nix~')
# ... snip ...
installing 'home-manager-path'
building '/nix/store/wnx75h3bcw1dfncnfjkfhwij4ilj8f3y-user-environment.drv'...
error: packages '/nix/store/p5rcp91yr7g2zl91xnph7wmnhhr8fp15-home-manager-path/bin/lorri' and '/nix/store/6jr3gabv3sg4l8ylsvydasm6lg1h1jv8-lorri-1.0/bin/lorri' have the same priority 5 
# ... snip ...
builder for '/nix/store/wnx75h3bcw1dfncnfjkfhwij4ilj8f3y-user-environment.drv' failed with exit code 1
error: build of '/nix/store/wnx75h3bcw1dfncnfjkfhwij4ilj8f3y-user-environment.drv' failed
```

That means you have `lorri` installed (or whatever package is at the end of the
nix path) with `nix-env -i` and it's clashing with `home-manager`. Uninstall it
with:

``` sh
# replacing lorri with the some-package-name from `/nix/store/some-hash-and-name/bin/some-package-name``
nix-env -e lorri 
```

Then run the script again:

``` sh
cd ~/path/to/smurf/nix/ghcide-setup
sh nix_install.sh # note sudo might be required to install curl if you don't have it already
```

This will leave you in a `nix-shell` as denoted in your prompt, just type `exit` like this:

``` sh
[nix-shell:~/smurf]$ exit
exit
cody@cody-VirtualBox:~/smurf/nix/ghcide-setup$ 
```

Add the appropriate shell hook:

``` sh
# ~/.zshrc
eval "$(direnv hook zsh)"
# ~/.bashrc
eval "$(direnv hook bash)"
# ~/.config/fish/config.fish
eval (direnv hook fish)
```

From now on things should be incremental and automatic. We should forever be in
a happy place and the direnv workflow is active with ghcide support. Let's
verify though.

Open a seperate terminal you'll always keep in view of lorri's logs:

``` sh
journalctl --user -fu lorri
```

Then in a different terminal window, cd into your smurf directory and allow
direnv:

``` sh
cody@cody-VirtualBox:~/smurf$ eval "$(direnv hook bash)" # if this isn't in your ~/.zshrc or ~/.config/home.nix you'll need to do this every time
direnv: error /home/cody/smurf/.envrc is blocked. Run `direnv allow` to approve its content
cody@cody-VirtualBox:~/smurf$ direnv allow
direnv: loading ~/smurf/.envrc
Jun 16 09:36:44.940 INFO lorri has not completed an evaluation for this project yet, expr: /home/cody/smurf/shell.nix
direnv: export +IN_NIX_SHELL
```

Then in your terminal window showing the lorri background daemon's logs you
should see a "build started" message immediately after doing `direnv allow` that
looks like:

```
Jun 16 11:41:01 cody-VirtualBox lorri[42929]: Jun 16 11:41:01.727 INFO build status, message: BuildEvent(Started { nix_file: Shell("/home/cody/smurf/shell.nix"), reason: PingReceived })
```

Followed shortly(hopefully) by:

```
Jun 16 11:41:16 cody-VirtualBox lorri[42929]: Jun 16 11:41:16.587 INFO build status, message: BuildEvent(Completed { nix_file: Shell("/home/cody/smurf/shell.nix"), result: BuildResults { output_paths: OutputPaths { shell_gc_root: RootPath("/home/cody/.cache/lorri/gc_roots/9258bb607f51cee0935651266a43868a/gc_root/shell_gc_root") } } })
```

If you see no such message, you can try reloading systemd daemon or reboot. Yes, seriously... it's a
[known bug](https://github.com/target/lorri/issues/374):

Reload like this:

``` sh
systemctl --user daemon-reload
```

```
cody@cody-VirtualBox:~/smurf$ systemctl --user daemon-reload
cody@cody-VirtualBox:~/smurf$ direnv reload
direnv: loading ~/smurf/.envrc
direnv: export +AR +AS +CABAL_CONFIG ... snip ...
```

If your window showing lorri's status still doesn't show the build
started/completed messages you have to reboot.


Now you can open a file like:

``` sh
codium ~/path/to/smurf/library/CsodApi.hs
```

Make sure in the bottom left you have selected `shell.nix` from `nix-env-selector`.

Then everything should work.


TODO: figure out how to get better caching by
[materializing](https://input-output-hk.github.io/haskell.nix/user-guide/materialization/)
import from derivations.


# Debugging nix/ghcide integration

### Something feels off....


Clear your caches (WARNING: nukes ~/.stack and other stuff)
``` sh
[cody@nixos:~/smurf]$ sh nix/ghcide-setup/clear-all-caches.sh 
```

Checkout your ghc-pkg cache:

``` sh
[cody@nixos:~/smurf]$ nix-shell --run "stack exec -- ghc-pkg list"
building '/nix/store/nm7jx67ja18s4jxcyzmya33w6hp5fyph-stack-repos.drv'...
...
# NOTE: all packages you care about should be under this section
/nix/store/sfr0jbrb7f4p9rjjjb9xdns80ic7bil4-ghc-shell-for-smurf-ghc-8.8.3-env/lib/ghc-8.8.3/package.conf.d
...
# NOTE: not under these stack sections
# NOTE: that should say "(no packages)"
/home/cody/.stack/snapshots/x86_64-linux/32afc83283f4da37bdd69380621055cb6a4668319465345e0e51e80091415829/8.8.3/pkgdb
    (no packages)
/home/cody/smurf/.stack-work/install/x86_64-linux/32afc83283f4da37bdd69380621055cb6a4668319465345e0e51e80091415829/8.8.3/pkgdb
    (no packages)
```


Check that `stack ghci` doesn't install packages via stack:

``` sh
cody@cody-VirtualBox:~/smurf$ nix-shell --run "stack ghci"
trace: Using latest index state for hoogle!
trace: WARNING: license "GPL-2.0-or-later AND BSD-3-Clause" not found
# ... snip ...
Using main module: 1. Package `smurf' component smurf:exe:smurf with main-is file: /home/cody/smurf/executable/Main.hs
[1 of 2] Compiling Main             ( /home/cody/.stack/setup-exe-src/setup-mPHDZzAJ.hs, /home/cody/.stack/setup-exe-src/setup-mPHDZzAJ.o )
[2 of 2] Compiling StackSetupShim   ( /home/cody/.stack/setup-exe-src/setup-shim-mPHDZzAJ.hs, /home/cody/.stack/setup-exe-src/setup-shim-mPHDZzAJ.o )
Linking /home/cody/.stack/setup-exe-cache/x86_64-linux/tmp-Cabal-simple_mPHDZzAJ_3.0.1.0_ghc-8.8.3 ...
# NOTE: if you see lines formatted like "> configure" stack is installing it's own stuff
# and not using the nix integration
bytestring-builder   > configure
bytestring-builder   > Configuring bytestring-builder-0.10.8.2.0...
bytestring-builder   > build
monad-loops          > configure
bytestring-builder   > Preprocessing library for bytestring-builder-0.10.8.2.0..
bytestring-builder   > Building library for bytestring-builder-0.10.8.2.0..
Progress 0/12^C
```
