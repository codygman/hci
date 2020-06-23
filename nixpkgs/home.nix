{ ... }:
let
  sources = import ./nix/sources.nix;
  emacs-overlay = sources.emacs-overlay;
  pkgs = import sources.nixpkgs { overlays = [ (import emacs-overlay) ]; };
  nivpkg = import sources.niv {};
  home-manager = import sources.home-manager { pkgs = pkgs; };
  myEnv = builtins.getEnv "MYENV";
  lib = pkgs.lib;
  extraConfigImports = if myEnv != ""
            then if myEnv == "personal" then
              lib.info "loading PERSONAL home manager environment"
                [ ~/Sync/nix-home-manager-config/personal.nix ]
                 else
                   if myEnv == "work" then
                     lib.info "loading WORK home manager environment"
                       [ ~/Sync/nix-home-manager-config/work.nix ]
                   else
                     lib.warn "MYENV is not one of 'personal' or 'work', ONLY core home environment will be available!" []
            else
              lib.warn "MYENV not specified, ONLY core home environment will be available!" [];
in
{
  nixpkgs  = {
    overlays = [
       (import "${emacs-overlay}")
    ];
  };

  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      userName = "codygman";
      userEmail = lib.mkDefault "cody@codygman.dev";
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
    };
    emacs = {
      enable = true;
      package = if builtins.getEnv "TRAVIS_OS_NAME" == "" then pkgs.emacs26 else pkgs.emacs26-nox;
      extraPackages = epkgs: [ epkgs.use-package epkgs.haskell-mode ];
    };
    bash = {
      enable = true;
      shellAliases = {
        new-haskell-project = "nix-shell -p cookiecutter git --run 'cookiecutter gh:codygman/hs-nix-template'";
      };
    };
    ssh = {
      enable = true;
    };
  };

  home = {
    packages = with pkgs; [ fd
                            ripgrep
                            # will need to ensure cachix by ci and cachix version here match
                            # cachix
                            source-code-pro
                            sqlite
                            gcc
                          ];
  };

  services = {
  };

}
