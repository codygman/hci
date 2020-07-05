# shell.nix
let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  hsPkgs = import ./default.nix {};
in
  hsPkgs.shellFor {

    # Include only the *local* packages of your project.
    packages = ps: with ps; [
      simple-haskell-project
    ];

    # Some common tools can be added with the `tools` argument
    tools = { cabal = "3.2.0.0"; hlint = "2.2.11"; ghcide = "0.2.0"; brittany = "0.12.1.1";};
    # See overlays/tools.nix for more details

    # Some you may need to get some other way.
    buildInputs = with pkgs.haskellPackages;
      [ stack ghcid pkgs.postgresql ];

    # Prevents cabal from choosing alternate plans, so that
    # *all* dependencies are provided by Nix.
    exactDeps = true;
  }
