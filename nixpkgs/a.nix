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

            diagrams-postscript = hself.haskell.lib.dontCheck ( # NOTE: not actually for sure ignoring deps is okay
              hself.haskell.lib.doJailbreak (
                hself.callHackageDirect 
                  { pkg = "diagrams-postscript";
                    ver = "1.4.1";
                    sha256 = "0174y4s6rx6cckkbhph22ybl96h00wjqqkzkrcni7ylxcvgf37bd";
                  } {}));


          });
      }
      );
  };
  # in mypkgs.myHaskellPackages.haskell-src-exts
in mypkgs.diagrams-builder
  # in mypkgs.myHaskellPackages.req
