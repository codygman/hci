let
  mypkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/c71518e75bf067fb639d44264fdd8cf80f53d75a.tar.gz") { overlays = [overlay]; };

  overlay = self: super: {

    diagrams-builder = super.diagrams-builder.override(old: {
      ghcWithPackages = null;
    });

    myHaskellPackages = 
      super.haskell.packages.ghc883.override (old: {

        overrides = self.lib.composeExtensions (old.overrides or (_: _: {})) 
          (hself: hsuper: {

            myGhcWithPackages = hself.ghc.withPackages;

            haskell-src-exts = self.haskell.lib.doJailbreak (
              hself.callHackageDirect 
                { pkg = "haskell-src-exts";
                  ver = "1.22.0";
                  sha256 = "1w1fzpid798b5h090pwpz7n4yyxw4hq3l4r493ygyr879dvjlr8d";
                } {});

            haskell-src-exts-simple = self.haskell.lib.doJailbreak (
              hself.callHackageDirect 
                { pkg = "haskell-src-exts-simple";
                  ver = "1.22.0.0";
                  sha256 = "1ixx2bpc7g6lclzrdjrnyf026g581rwm0iji1mn1iv03yzl3y215";
                } {});

            diagrams-postscript = self.haskell.lib.doJailbreak (
              hself.callHackageDirect 
                { pkg = "diagrams-postscript";
                  ver = "1.4.1";
                  sha256 = "0174y4s6rx6cckkbhph22ybl96h00wjqqkzkrcni7ylxcvgf37bd";
                } {});

            diagrams-builder = self.haskell.lib.doJailbreak (
              hsuper.diagrams-builder);

          });
      }
      );
  };

in mypkgs.diagrams-builder

# error
# Setup: Encountered missing or private dependencies:
# haskell-src-exts >=1.18 && <1.23,
# haskell-src-exts-simple >=1.18 && <1.23

# builder for '/nix/store/abggggz6k0wwalyc6p22czp6swdh4k81-diagrams-builder-0.8.0.5.drv' failed with exit code 1
# cannot build derivation '/nix/store/g62x0xqf6fhk7lmryvzx7yga04v5adzd-diagrams-builder.drv': 1 dependencies couldn't be built
# error: build of '/nix/store/g62x0xqf6fhk7lmryvzx7yga04v5adzd-diagrams-builder.drv' failed



# works
# in mypkgs.myHaskellPackages.diagrams-builder





  # error:
  # error: infinite recursion encountered, at /home/cody/hci/nixpkgs/b.nix:10:13
  # (use '--show-trace' to show detailed location information)

  # verify it works without my overriden version; it does

  # in mypkgs.diagrams-builder.override( { ghcWithPackages = mypkgs.haskellPackages.ghcWithPackages; } )

  # first thought this would work, no luck

  # in mypkgs.diagrams-builder { ghcWithPackages = mypkgs.myHaskellPackages.ghcWithPackages; }

  # looked at the source of diagrams-builder.nix, see ghcWithPackages can be passed in
