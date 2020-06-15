{ sources }:
let
  # TODO use niv
  nix-doom-emacs = import sources.nix-doom-emacs;
  emacs-overlay = builtins.fetchTarball "https://github.com/nix-community/emacs-overlay/archive/52b9fd468cd45f85c43f9b623ed2854971d8e1ad.tar.gz";
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
in
  with pkgs; callPackage nix-doom-emacs {
    bundledPackages = false;
    emacsPackages = emacsPackagesFor emacsGit;
    doomPrivateDir = ./doom;
  }
