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
  myemacs = import ./emacs.nix {pkgs = pkgs;};
in
{
  imports = mylib.loadPrivatePersonalOrWorkEnv ;

  # TODO why do we have two different overlays for this expression body and in the pkgs import??
  nixpkgs = {
    overlays = [
      (import sources.emacs-overlay)
    ];
  };

  xsession = {
    enable = true;
    windowManager.command = ''
      ${myemacs}/bin/emacs --eval '(progn (server-start) (exwm-enable))'
    '';
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
      package = myemacs;
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
    picom = {
      enable = true;
    };
    lorri = {
      package = mylorri;
      enable = true;
    };
    syncthing = {
      enable = true;
    };
    redshift = {
      enable = false;
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
