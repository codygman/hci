let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/c71518e75bf067fb639d44264fdd8cf80f53d75a.tar.gz") { overlays = [overlay]; };
  overlay = self: super: {
    myHaskellPackages = 
      super.haskell.packages.ghc883.override (old: {
        overrides = self.lib.composeExtensions (old.overrides or (_: _: {})) 
          (hself: hsuper: {
            diagrams-builder =  hself.callHackageDirect 
              { pkg = "haskell-src-exts";
                ver = "0.8.0.4";
                sha256 = "0000000000000000000000000000000000000000000000000000";
              } {};
          });
      });
  };

in pkgs.haskell.packages.ghc883.diagrams-builder
