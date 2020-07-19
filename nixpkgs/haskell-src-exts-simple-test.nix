# see diagrams-builder.nix, this is a simpler version trying to solve subproblem of building haskell-src-exts-simple

let pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/c71518e75bf067fb639d44264fdd8cf80f53d75a.tar.gz") {};
    # haskellPackages = 
    my-haskell-src-exts =
      pkgs.haskellPackages.callHackageDirect 
        { pkg = "haskell-src-exts";
          ver = "1.22.0";
          sha256 = "0jwp8vhk3ncfxprbmg0jx001g7mh1kyp16973mjkjqz0d60zarwi";
        } {};
    my-haskell-src-exts-simple =
      pkgs.haskellPackages.callHackageDirect 
        { pkg = "haskell-src-exts-simple";
          ver = "1.22.0.0";
          sha256 = "1ixx2bpc7g6lclzrdjrnyf026g581rwm0iji1mn1iv03yzl3y215";
        } {};
in my-haskell-src-exts-simple.override( {
  overrides = _: _: {
    haskell-src-exts = my-haskell-src-exts;
  };
})
