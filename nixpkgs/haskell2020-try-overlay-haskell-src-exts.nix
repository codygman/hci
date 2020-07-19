let
  sources = import ./nix/sources.nix;
  mypkgs = import sources.nixpkgs {
    overlays = [overlay];
  };
  overlay = self: super: {
    myHaskellPackages = 
      super.haskell.packages.ghc883.override (old: {
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
in mypkgs.haskell.packages.ghc883.haskell-src-exts
