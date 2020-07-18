{ config, ... }:
# TODO verify pkgs above is pinned as a result
let
  sources = import ./nix/sources.nix;
  emacs-overlay = sources.emacs-overlay {};
  mylorripkg = sources.lorri;
  pkgs = import sources.nixpkgs { overlays = [ (import sources.emacs-overlay) ];};
  myHaskellNixPkgs = pkgs;
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
        ob-diagrams
        ob-restclient
        direnv
        doom-themes
        flycheck
        flycheck-haskell
        general
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
      # myHaskellNixPkgs.diagrams-builder

      # try jailbreaking
      (myHaskellNixPkgs.diagrams-builder.overrideAttrs
        (oldAttrs: {
          haskell-src-exts = myHaskellNixPkgs.haskellPackages.callHackageDirect 
            { pkg = "haskell-src-exts";
              ver = "1.22.0";
              sha256 = "0jwp8vhk3ncfxprbmg0jx001g7mh1kyp16973mjkjqz0d60zarwi";
            } {};
          haskell-src-exts-simple = myHaskellNixPkgs.haskellPackages.callHackageDirect 
            { pkg = "haskell-src-exts-simple";
              ver = "1.22.0.0";
              sha256 = "1ixx2bpc7g6lclzrdjrnyf026g581rwm0iji1mn1iv03yzl3y215";
            } {};
          diagrams-postscript = pkgs.haskell.lib.dontCheck ( # NOTE: not actually for sure ignoring deps is okay
            pkgs.haskell.lib.doJailbreak (
              myHaskellNixPkgs.haskellPackages.callHackageDirect 
                { pkg = "diagrams-postscript";
                  ver = "1.4.1";
                  sha256 = "0174y4s6rx6cckkbhph22ybl96h00wjqqkzkrcni7ylxcvgf37bd";
                } {}));
          diagrams-builder = pkgs.haskell.lib.doJailbreak (
            pkgs.haskell.lib.dontCheck (
              myHaskellNixPkgs.haskell.packages.ghc883.diagrams-builder));
        }))

      # TODO ghcWithHoogle
      (myHaskellNixPkgs.haskell.packages.ghc883.ghcWithPackages (p: [
        # p.diagrams
        # Yep, need diagrams-builder-cairo
        # p.diagrams-builder #oops this is broken and likely needed for ob-diagrams
        # ( pkgs.haskellPackages.callCabal2nix "diagrams-builder" (sources.diagrams-builder ) )
        # ( pkgs.haskellPackages.callCabal2nix "diagrams-builder" (sources.diagrams-builder { jailbreak = true; }) )

        # ( (pkgs.haskellPackages.callCabal2nix "diagrams-builder" (sources.diagrams-builder )) { jailbreak = true; }  )
        # p.diagrams-contrib
        p.lens
        # p.hoogle
      ]))
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
