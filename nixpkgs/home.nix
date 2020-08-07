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
        counsel
        company
        company-lsp
        use-package
        haskell-mode
        elm-mode
        exwm
        evil
        evil-magit
        evil-collection
        ( forge.override (args: {
          melpaBuild = drv: args.melpaBuild (drv // {
            src = pkgs.fetchFromGitHub {
              owner = "magit";
              repo = "forge";
              rev = "2c487465d0b78ffe34252b47fcc06e27039330c4";
              sha256 = "08c44ljvni2rr8d8ph3rzw7qrj7czx94m50bx455d8vv0snx0sv6";
            };
          });
        }) )
        helm
        helm-projectile
        ( helm-rg.override (args: {
          melpaBuild = drv: args.melpaBuild (drv // {
            src = pkgs.fetchFromGitHub {
              owner = "cosmicexplorer";
              repo = "helm-rg";
              rev = "ee0a3c09da0c843715344919400ab0a0190cc9dc";
              sha256 = "0m4l894345n0zkbgl0ar4c93v8pyrhblk9zbrjrdr9cfz40bx2kd";
            };
          });
        }) )
        helm-swoop
        ivy
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
        ( lsp-haskell.override (args: {
          melpaBuild = drv: args.melpaBuild (drv // {
            src = pkgs.fetchFromGitHub {
              owner = "emacs-lsp";
              repo = "lsp-haskell";
              rev = "17d7d4c6615b5e6c7442828720730bfeda644af8";
              sha256 = "1kkp63ppmi3p0p6qkfpkr8p5cx8qggmsj73dwphv90mdq0nrfsx8";
            };
          });
        }) )
        ( lsp-ui.override (args: {
          melpaBuild = drv: args.melpaBuild (drv // {
            src = pkgs.fetchFromGitHub {
              owner = "emacs-lsp";
              repo = "lsp-ui";
              rev = "7d5326430eb88a58e111cb22ffa42c7d131e5052";
              sha256 = "1f2dxxajckwqvpl8cxsp019404sncllib5z2af0gzs7y0fs7b2dq";
            };
          });
        }) )
        magit
        nix-mode
        ob-restclient
        ox-gfm
        direnv
        doom-themes
        flycheck
        flycheck-haskell
        general
        olivetti
        projectile
        ts
        with-simulated-input
        which-key
        yasnippet
      ];
    };


    git = {
      enable = true;
      userName = "codygman";
      userEmail = lib.mkDefault "cody@codygman.dev";
      extraConfig = {
        github = {
          user = "codygman";
        };
      };
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
      xvfb_run
    ];
  };

  services = {
    lorri = {
      package = mylorri;
      enable = true;
    };
    syncthing = {
      enable = true;
    };
    redshift = {
      enable = true;
      latitude = "32.7767";
      longitude = "96.7970";
      brightness = {
        day = "0.4";
        night = "0.4";
      };
      tray = false;
      provider = "manual";
      temperature = {
        day = 3501;
        night = 3501;
      };
      extraOptions = ["-v"];
    };
  };

}
