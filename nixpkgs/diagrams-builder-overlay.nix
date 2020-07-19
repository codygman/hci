let
  pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/c71518e75bf067fb639d44264fdd8cf80f53d75a.tar.gz") { overlays = [overlay]; };
  overlay = self: super: {
    myHaskellPackages = 
      super.haskellPackages.override (old: {
        overrides = self.lib.composeExtensions (old.overrides or (_: _: {})) 
          (hself: hsuper: {
            haskell-src-exts = self.callHackageDirect 
              { pkg = "haskell-src-exts";
                ver = "1.22.0";
                sha256 = "0jwp8vhk3ncfxprbmg0jx001g7mh1kyp16973mjkjqz0d60zarwi";
              } {};
          });
      });
  };

in pkgs.diagrams-builder
