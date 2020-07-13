{ config, ... }:
# TODO verify pkgs above is pinned as a result
let
  sources = import ./nix/sources.nix;
  emacs-overlay = sources.emacs-overlay {};
  mylorripkg = sources.lorri;
  pkgs = import sources.nixpkgs { overlays = [ (import sources.emacs-overlay) ];};
  mylorri = pkgs.callPackage mylorripkg {};
  home-manager = import sources.home-manager {};
  myEnv = builtins.getEnv "MYENV";
  lib = pkgs.lib;
  mylib = import ./nix/mylib.nix {pkgs = pkgs;};
in
{
  imports = mylib.loadPrivatePersonalOrWorkEnv ;

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

    vim.enable = true;

    emacs = {
      enable = true;
      # package = if builtins.getEnv "TRAVIS_OS_NAME" == "" then emacs-overlay.emacs else pkgs.emacs-nox;
      package = pkgs.emacsGit;
      extraPackages = epkgs: with epkgs; [
        async
        buttercup
        company
        company-lsp
        use-package
        haskell-mode
        evil
        evil-magit
        evil-collection
        ivy
        ivy-posframe
        counsel
        swiper
        counsel-projectile
        ( lsp-mode.override (args: {
          melpaBuild = drv: args.melpaBuild (drv // {
            src = pkgs.fetchFromGitHub {
              owner = "emacs-lsp";
              repo = "lsp-mode";
              rev = "3aad14064cccf530ff58ffc4263bd99de44e9fe1";
              sha256 = "0w5plh0z6x1pijw3g05lz7p69jm49yay8iw86scb7d00fsmnci3s";
            };
          });
        }) )
        lsp-haskell
        lsp-ui
        magit
        nix-mode
        direnv
        doom-themes
        flycheck
        flycheck-haskell
        general
        projectile
        ts
        with-simulated-input
        which-key
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
    keychain = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
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

    packages = with pkgs; [
      # cachix # not sure what was wrong here
      # ghcide # having this by default would be nice for the ghc I'm using most at the time
      # home-manager.home-manager
      mylorri # TODO
      # niv # not defined?
      # will need to ensure cachix by ci and cachix version here match
      cmake
      coreutils
      fd
      firefox
      gcc
      gcc
      ghc
      gnumake
      graphviz
      libnotify
      nox
      ripgrep
      signal-desktop
      source-code-pro
      sqlite
      sqlite
      stack
    ];
  };

  services = {
    lorri = {
      package = mylorri;
      enable = true;
    };
    redshift = {
      enable = true;
      latitude = "32.7767";
      longitude = "96.7970";
      brightness = {
        # Day and night mixed up, lol
        day = "0.4";
        night = "0.8";
      };
      tray = false;
      provider = "manual";
      temperature = {
        # Day and night mixed up, lol
        night = 5501;
        day = 3501;
      };
      extraOptions = ["-v"];
    };
  };

}
