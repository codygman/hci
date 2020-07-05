## Current

This works only after explicitly (and ironically) disabling stack's own nix support, with:

``` yaml
# stack.yaml
resolver: lts-16.0
system-ghc: true
install-ghc: false
nix:
  enable: false
```

``` sh
$ git clone git@github.com:codygman/haskell-nix-stack-workflow.git
$ git checkout a53d2278caf56e4d601530708ea37eac2335d7c4
$ nix build -f . myproj.components.library
trace: To make this a fixed-output derivation but not materialized, set `stack-sha256` to the output of /nix/store/v342rl2h6r4sdwy6nh9wyv2bfkzacaq8-calculateSha
trace: To materialize the output entirely, pass a writable path as the `materialized` argument and pass that path to /nix/store/48yg4aykx3ygvhk1kxn1r7bl0k8s6hib-generateMaterialized
trace: Cleaning component source not supported for hpack package: myproj-0.1.0.0
[nix-shell]$ stack ghci
Using main module: 1. Package `myproj' component myproj:exe:myproj-exe with main-is file: /tmp/haskell-nix-stack-workflow/app/Main.hs
Building all executables for `myproj' once. After a successful build of all of them, only specified executables will be rebuilt.
myproj> configure (lib + exe)
Configuring myproj-0.1.0.0...
myproj> initial-build-steps (lib + exe)
The following GHC options are incompatible with GHCi and have not been passed to it: -threaded
Configuring GHCi with the following packages: myproj
GHCi, version 8.8.3: https://www.haskell.org/ghc/  :? for help
[1 of 2] Compiling Lib              ( /tmp/haskell-nix-stack-workflow/src/Lib.hs, interpreted )
[2 of 2] Compiling Main             ( /tmp/haskell-nix-stack-workflow/app/Main.hs, interpreted )
Ok, two modules loaded.
Loaded GHCi configuration from /run/user/1000/haskell-stack-ghci/9962e459/ghci-script
*Main Lib> import Database.PostgreSQL.Simple
*Main Lib Database.PostgreSQL.Simple> :t connect
connect :: ConnectInfo -> IO Connection

```

## First attempt (before learning stack/nix integration issues)

### Simplest case (no dependencies)

Build works. `stack ghci` works.

##### Initial build:

``` sh
[cody@nixos:~/code/haskell-nix-stack-workflow]$ git clone git@github.com:codygman/haskell-nix-stack-workflow.git
[cody@nixos:~/code/haskell-nix-stack-workflow]$ git checkout e66a50e2be2706724174b2e7d3c5e4a884f42179
[cody@nixos:~/code/haskell-nix-stack-workflow]$ nix build -f . myproj.components.library
trace: To make this a fixed-output derivation but not materialized, set `stack-sha256` to the output of /nix/store/39l8cnr4ykzsp41qah7zv0v288031xh3-calculateSha
trace: To materialize the output entirely, pass a writable path as the `materialized` argument and pass that path to /nix/store/ccwvl1maab5sj9z1kjqi0r87pcibxdzc-generateMaterialized
trace: Cleaning component source not supported for hpack package: myproj-0.1.0.0
```

##### Open a shell in the haskell.nix environment

``` sh
[cody@nixos:~/code/haskell-nix-stack-workflow]$ nix-shell -A shellFor
trace: To make this a fixed-output derivation but not materialized, set `stack-sha256` to the output of /nix/store/39l8cnr4ykzsp41qah7zv0v288031xh3-calculateSha
trace: To materialize the output entirely, pass a writable path as the `materialized` argument and pass that path to /nix/store/ccwvl1maab5sj9z1kjqi0r87pcibxdzc-generateMaterialized
copying path '/nix/store/kkps3hc2gsr7b0ppbpnh9kvd3xnwdpw5-ghc883-boot-packages-nix.nix' from 'https://iohk.cachix.org'...
trace: Shell for myproj
trace: Using latest index state for hoogle!
trace: WARNING: license "GPL-2.0-or-later AND BSD-3-Clause" not found
trace: Using index-state: 2020-06-14T00:00:00Z for hoogle
these derivations will be built:
  /nix/store/kniz6a8065z772fqil557qdimpimj47k-hoogle-local-0.1.drv
  /nix/store/y9max1d10d4rqv8hzk9gzifaprjx5bw0-ghc-shell-for-myproj-config.drv
  /nix/store/47m2a9ymm85xskm91hdm3xs4pbll7lwp-ghc-shell-for-myproj-ghc-8.8.3-env.drv
these paths will be fetched (18.34 MiB download, 271.12 MiB unpacked):
  /nix/store/ljkbw4960a5wp54by0fr9hwjawa2l55x-ghc-8.8.3-doc
copying path '/nix/store/ljkbw4960a5wp54by0fr9hwjawa2l55x-ghc-8.8.3-doc' from 'https://iohk.cachix.org'...
building '/nix/store/y9max1d10d4rqv8hzk9gzifaprjx5bw0-ghc-shell-for-myproj-config.drv'...
building '/nix/store/kniz6a8065z772fqil557qdimpimj47k-hoogle-local-0.1.drv'...
WARNING: localHoogle package list empty, even though the following were specified:
importing builtin packages
importing other packages
building hoogle database
Starting generate
[3/32] base... 1.11s
[10/32] ghc... 2.85s
[26/32] template-haskell... 0.19s
[32/32] xhtml... 0.08s
Found 24 warnings when processing items

Reordering items... 0.02s
Writing tags... 0.16s
Writing names... 0.06s
Writing types... 0.88s
Took 8.35s
building haddock index
finishing up
building '/nix/store/47m2a9ymm85xskm91hdm3xs4pbll7lwp-ghc-shell-for-myproj-ghc-8.8.3-env.drv'...


```

We have a working ghci from `stack ghci`? Good? Why? Okay, awesome:

``` sh
[nix-shell:~/code/haskell-nix-stack-workflow]$ stack ghci
Using main module: 1. Package `myproj' component myproj:exe:myproj-exe with main-is file: /home/cody/code/haskell-nix-stack-workflow/app/Main.hs
[1 of 2] Compiling Main             ( /home/cody/.stack/setup-exe-src/setup-mPHDZzAJ.hs, /home/cody/.stack/setup-exe-src/setup-mPHDZzAJ.o )
[2 of 2] Compiling StackSetupShim   ( /home/cody/.stack/setup-exe-src/setup-shim-mPHDZzAJ.hs, /home/cody/.stack/setup-exe-src/setup-shim-mPHDZzAJ.o )
Linking /home/cody/.stack/setup-exe-cache/x86_64-linux-nix/tmp-Cabal-simple_mPHDZzAJ_3.0.1.0_ghc-8.8.3 ...
Building all executables for `myproj' once. After a successful build of all of them, only specified executables will be rebuilt.
myproj> configure (lib + exe)
Configuring myproj-0.1.0.0...
myproj> initial-build-steps (lib + exe)
The following GHC options are incompatible with GHCi and have not been passed to it: -threaded
Configuring GHCi with the following packages: myproj
GHCi, version 8.8.3: https://www.haskell.org/ghc/  :? for help
[1 of 2] Compiling Lib              ( /home/cody/code/haskell-nix-stack-workflow/src/Lib.hs, interpreted )
[2 of 2] Compiling Main             ( /home/cody/code/haskell-nix-stack-workflow/app/Main.hs, interpreted )
Ok, two modules loaded.
Loaded GHCi configuration from /run/user/1000/haskell-stack-ghci/1df5176e/ghci-script
*Main Lib> :browse Lib
someFunc :: IO ()
*Main Lib> :q
Leaving GHCi.
```

This works.


### Simplest case (no dependencies)

Build works. `stack ghci` tries to download dependencies even with [attempted workaround](https://github.com/commercialhaskell/stack/issues/3617#issuecomment-418206574).

##### Adding a haskell library with a native dependency (HsOpenSSL)

``` diff
modified   package.yaml
@@ -21,6 +21,7 @@ description:         Please see the README on GitHub at <https://github.com/gith
 
 dependencies:
 - base >= 4.7 && < 5
+- postgresql-simple
```

Then if we exit out of nix-shell, build, and re-enter nix-shell:

``` sh
[cody@nixos:~/code/haskell-nix-stack-workflow]$ nix build -f . myproj.components.library
trace: To make this a fixed-output derivation but not materialized, set `stack-sha256` to the output of /nix/store/qi3n6m8s5yqplh9ws4zkb9cb4hmnsvzx-calculateSha
trace: To materialize the output entirely, pass a writable path as the `materialized` argument and pass that path to /nix/store/00r7v1asp618pg9ivvg4pykxwsgafzjd-generateMaterialized
trace: Cleaning component source not supported for hpack package: myproj-0.1.0.0

[cody@nixos:~/code/haskell-nix-stack-workflow]$ nix-shell -A shellFor
[nix-shell:~/code/haskell-nix-stack-workflow]$ stack --stack-yaml stack-nix.yaml ghci
Using main module: 1. Package `myproj' component myproj:exe:myproj-exe with main-is file: /home/cody/code/haskell-nix-stack-workflow/app/Main.hs
base-compat-batteries> configure
base-compat-batteries> Configuring base-compat-batteries-0.11.1...
base-compat-batteries> build
postgresql-libpq     > configure
base-compat-batteries> Preprocessing library for base-compat-batteries-0.11.1..
base-compat-batteries> Building library for base-compat-batteries-0.11.1..
postgresql-libpq     > [1 of 2] Compiling Main             ( /run/user/1000/stack-cacf6a20219f4590/postgresql-libpq-0.9.4.2/Setup.hs, /run/user/1000/stack-cacf6a20219f4590/postgresql-libpq-0.9.4.2/.stack-work/dist/x86_64-linux-nix/Cabal-3.0.1.0/setup/Main.o )
postgresql-libpq     > [2 of 2] Compiling StackSetupShim   ( /home/cody/.stack/setup-exe-src/setup-shim-mPHDZzAJ.hs, /run/user/1000/stack-cacf6a20219f4590/postgresql-libpq-0.9.4.2/.stack-work/dist/x86_64-linux-nix/Cabal-3.0.1.0/setup/StackSetupShim.o )
postgresql-libpq     > Linking /run/user/1000/stack-cacf6a20219f4590/postgresql-libpq-0.9.4.2/.stack-work/dist/x86_64-linux-nix/Cabal-3.0.1.0/setup/setup ...
Progress 0/12  C-c C-c
```
