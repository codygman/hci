# shell.nix
let
  hsPkgs = import ./default.nix {};
in
  hsPkgs.simple-haskell-project.components.all
