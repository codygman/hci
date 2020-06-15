let
  emacs-overlay = builtins.fetchTarball "https://github.com/nix-community/emacs-overlay/archive/52b9fd468cd45f85c43f9b623ed2854971d8e1ad.tar.gz";
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  nix-doom-emacs = builtins.fetchTarball "https://github.com/vlaci/nix-doom-emacs/archive/303b511350e013f7b579c396e2a98e9174f30d22.tar.gz";
in
  with pkgs; callPackage nix-doom-emacs {
    bundledPackages = false;
    emacsPackages = emacsPackagesFor emacsGit;
    doomPrivateDir = ./doom;
  }
