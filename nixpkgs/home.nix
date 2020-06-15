{ pkgs, ... }:
let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {};
  nivpkg = import sources.niv {};
  home-manager = import sources.home-manager { pkgs = pkgs; };
  doom-emacs = import ./doomemacs.nix { sources = sources; };
  myEnv = builtins.getEnv "MYENV";
  lib = pkgs.lib;
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
    packages = with pkgs; [ doom-emacs fd ripgrep source-code-pro sqlite gnumake nox gcc coreutils cmake graphviz nivpkg.niv libnotify];
  };

  services = {
    lorri.enable = true;
    syncthing = {
      enable = true;
    };
  };

}
