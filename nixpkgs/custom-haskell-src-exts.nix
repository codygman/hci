let pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/c71518e75bf067fb639d44264fdd8cf80f53d75a.tar.gz") {};
    my-haskell-src-exts =
      pkgs.haskellPackages.callHackageDirect 
        { pkg = "haskell-src-exts";
          ver = "1.22.0";
          sha256 = "1w1fzpid798b5h090pwpz7n4yyxw4hq3l4r493ygyr879dvjlr8d";
        } {};
in my-haskell-src-exts
