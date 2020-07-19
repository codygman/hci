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

            ghcWithPackages = hself.ghc.withPackages;

            haskell-src-exts = hself.callHackageDirect 
              { pkg = "haskell-src-exts";
                ver = "1.22.0";
                sha256 = "1w1fzpid798b5h090pwpz7n4yyxw4hq3l4r493ygyr879dvjlr8d";
              } {};



          });
      }
      );
  };
# in mypkgs.myHaskellPackages.haskell-src-exts
in mypkgs.diagrams-builder
# in mypkgs.myHaskellPackages.req
