let
  sources = import ./nix/sources.nix;
  haskellNix = import sources."haskell.nix" {};
  nixpkgsSrc = haskellNix.sources.nixpkgs-2003;
  nixpkgsArgs = haskellNix.nixpkgsArgs;

in
{ pkgs ? import nixpkgsSrc nixpkgsArgs }:
pkgs.haskell-nix.stackProject {
  src = pkgs.nix-gitignore.gitignoreSource [] ./.;
  compiler-nix-name = "ghc883";
}
