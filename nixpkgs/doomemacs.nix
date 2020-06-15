{ sources, pkgs }:
let
  nix-doom-emacs = import sources.nix-doom-emacs;
in
  with pkgs; callPackage nix-doom-emacs {
    bundledPackages = false;
    emacsPackages = emacsPackagesFor emacsGit;
    doomPrivateDir = ./doom;
  }
