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
  nixpkgs.config.allowUnfree = true;
  home.file.".config/nixpkgs/config.nix".text = ''
    { allowUnfree = true; }
  '';
  imports = mylib.loadPrivatePersonalOrWorkEnv ;

  xsession = {
    enable = true;
    windowManager.command = ''
                           ${myemacs}/bin/emacs --daemon -f exwm-enable
                           exec ${myemacs}/bin/emacsclient -c
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
      alacritty
      # cachix # not sure what was wrong here
      # ghcide # having this by default would be nice for the ghc I'm using most at the time
      # home-manager.home-manager
      mylorri # TODO
      # niv # not defined?
      # will need to ensure cachix by ci and cachix version here match
      cmake
      coreutils
      dbeaver
      jq
      awscli
      discord
      fd
      firefox
      gcc
      (haskellPackages.ghcWithPackages (pkgs: [pkgs.lens pkgs.generic-lens]))
      gnumake
      graphviz
      libnotify
      (let neuronSrc = builtins.fetchTarball "https://github.com/srid/neuron/archive/8894f9449d04b05d58f41c9b71472333eaaa4471.tar.gz"; in import neuronSrc {})
      nox
      ripgrep
      signal-desktop
      source-code-pro
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
        day = 4501;
        night = 4501;
      };
      extraOptions = ["-v"];
    };
  };

}
