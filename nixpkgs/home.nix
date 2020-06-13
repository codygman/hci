{ config, pkgs, home, ... }:

with import <nixpkgs> {};
with lib;

let
  emacs-overlay = builtins.fetchTarball "https://github.com/nix-community/emacs-overlay/archive/52b9fd468cd45f85c43f9b623ed2854971d8e1ad.tar.gz";
  pkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  doom-emacs = with pkgs; callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/9337a8741ea79084642a430c4b01814377530424.tar.gz;
  }) {
    bundledPackages = false;
    emacsPackages = emacsPackagesFor emacsGit;
    doomPrivateDir = ./doom.d;  # Directory containing your config.el init.el
    # and packages.el files
  };
  myEnv = builtins.getEnv "MYENV";
in
{
  imports = if myEnv != ""
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
    packages = with pkgs; [ doom-emacs fd ripgrep source-code-pro sqlite gnumake nox gcc coreutils cmake graphviz niv libnotify];
  };

  services = {
    lorri.enable = true;
    syncthing = {
      enable = true;
    };
  };

}
