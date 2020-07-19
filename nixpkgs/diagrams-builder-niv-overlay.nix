let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs
    {
      overlays = [
        (
          self: super: {
            
            haskell-src-exts = self.callHackageDirect 
              { pkg = "haskell-src-exts";
                ver = "1.22.0";
                sha256 = "0jwp8vhk3ncfxprbmg0jx001g7mh1kyp16973mjkjqz0d60zarwi";
              } {};

          }
        )
      ];
    };
in
pkgs.haskellPackages.haskell-src-exts
