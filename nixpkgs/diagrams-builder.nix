# Command
# nix-build diagrams-builder.nix 

# Error
#
# Setup: Encountered missing or private dependencies:
# haskell-src-exts ==1.22.*

# builder for '/nix/store/9mwklkck5gjjd0adk2jdkrm5zbhyy16b-haskell-src-exts-simple-1.22.0.0.drv' failed with exit code 1
# cannot build derivation '/nix/store/iw613czqivarhr12xbgj8rri7j4m0w8x-diagrams-builder.drv': 1 dependencies couldn't be built
# error: build of '/nix/store/iw613czqivarhr12xbgj8rri7j4m0w8x-diagrams-builder.drv' failed

# Code
let pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs-channels/archive/c71518e75bf067fb639d44264fdd8cf80f53d75a.tar.gz") {};
    myHaskellPackages = pkgs.haskellPackages.override {
      overrides = self: super: {
        haskell-src-exts = self.callHackageDirect 
          { pkg = "haskell-src-exts";
            ver = "1.22.0";
            sha256 = "0jwp8vhk3ncfxprbmg0jx001g7mh1kyp16973mjkjqz0d60zarwi";
          } {};
        haskell-src-exts-simple = 
          self.callHackageDirect 
            { pkg = "haskell-src-exts-simple";
              ver = "1.22.0.0";
              sha256 = "1ixx2bpc7g6lclzrdjrnyf026g581rwm0iji1mn1iv03yzl3y215";
            } {};
      };
    };
in myHaskellPackages.diagrams-builder

  # in pkgs.diagrams-builder.override( {
  #       diagrams-builder = myHaskellPackages.diagrams-builder;
  # })
  # in pkgs.diagrams-builder


  # in pkgs.diagrams-builder.overrideAttrs( oldAttrs : rec {
  #   haskell-src-exts = my-haskell-src-exts;
  #   haskell-src-exts-simple = my-haskell-src-exts-simple;
  # })






  # an attempt at https://github.com/NixOS/nixpkgs/issues/25887
  # in pkgs.diagrams-builder.overrideAttrs(old: {
  #   overrides = pkgs.lib.composeExtensions (old.overrides or (_: _: {})) (self: super: {});
  # })


  # (pkgs.diagrams-builder.overrideAttrs
  #   (oldAttrs: {
  #     haskell-src-exts = my-haskell-src-exts;
  #     haskell-src-exts-simple = my-haskell-src-exts-simple;
  #     diagrams-builder = 
  #       pkgs.haskell.packages.ghc883.diagrams-builder.override( {
  #         haskell-src-exts = my-haskell-src-exts;
  #         haskell-src-exts-simple = my-haskell-src-exts-simple;
  #       });
  #   }))
