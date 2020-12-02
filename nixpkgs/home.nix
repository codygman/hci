{ config, ... }:
# TODO verify pkgs above is pinned as a result
let
  sources = import ./nix/sources.nix;
  emacs-overlay = sources.emacs-overlay {};
  mylorripkg = sources.lorri;
  pkgs = import sources.nixpkgs { overlays = [ (import sources.emacs-overlay) ]; config = { allowUnfree = true; }; };
  mylorri = pkgs.callPackage mylorripkg {};
  home-manager = import sources.home-manager {};
  myEnv = builtins.getEnv "MYENV";
  lib = pkgs.lib;
  mylib = import ./nix/mylib.nix {pkgs = pkgs;};
  myemacs = import ./emacs.nix {pkgs = pkgs;};
in
{
  imports = mylib.loadPrivatePersonalOrWorkEnv ;

  fonts.fontconfig.enable = true;
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

    file = {
      ".ghci".text = ''
import Control.Lens
import Data.Aeson
import Data.Csv
import qualified Data.Map as M
import qualified Data.Vector as V
import qualified Data.ByteString as BS
import qualified Data.ByteString.IO as BS
import qualified Data.ByteString.Lazy as LBS
import qualified Data.ByteString.Lazy.IO as LBS
-- import qualified Hreq.Client as Hreq
'';
    };

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
      emacs-all-the-icons-fonts
      jq
      awscli
      discord
      fd
      firefox
      gcc
      (haskellPackages.ghcWithPackages (h: [h.lens h.generic-lens h.aeson h.cassava h.megaparsec h.turtle h.conduit h.lens h.req h.servant])) # hreq-client broken
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
