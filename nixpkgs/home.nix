{ config, ... }:
# TODO verify pkgs above is pinned as a result
let
  sources = import ./nix/sources.nix;
  emacs-overlay = sources.emacs-overlay {};
  pkgs = import sources.nixpkgs { overlays = [ (import sources.emacs-overlay) ];};
  home-manager = import sources.home-manager {};
  myEnv = builtins.getEnv "MYENV";
  lib = pkgs.lib;
in
{

 # TODO why do we have two different overlays for this expression body and in the pkgs import??
 nixpkgs = {
    overlays = [
       (import sources.emacs-overlay)
    ];
  };

  programs = {
    home-manager = {
      enable = true;
      # this uses the pinned version of home-manager
      path = "${home-manager.path}";
    };

    emacs = {
      enable = true;
      # package = if builtins.getEnv "TRAVIS_OS_NAME" == "" then emacs-overlay.emacs else pkgs.emacs-nox;
      package = pkgs.emacsGit;
      extraPackages = epkgs: with epkgs; [
        buttercup
        use-package
        haskell-mode
        evil
        evil-collection
        magit
	direnv
	doom-themes
      ];
    };


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

    keyboard = {
      layout = "us";
      options = [ "ctrl:nocaps" ];
    };

    packages = with pkgs; [ fd
                            ripgrep
                            # will need to ensure cachix by ci and cachix version here match
                            # cachix
                            ghc
			    stack
                            source-code-pro
                            sqlite
                            gcc
                          ];
  };

  services = {
    lorri.enable = true;
  };

}
