{ ... }:
let
  sources = import ./nix/sources.nix;
  emacs-overlay = sources.emacs-overlay;
  pkgs = import sources.nixpkgs { overlays = [ (import emacs-overlay) ]; };
  nivpkg = import sources.niv {};
  home-manager = import sources.home-manager { pkgs = pkgs; };
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
  };

  home = {
    packages = with pkgs; [ emacs
                            fd
                            ripgrep
                            source-code-pro
                            sqlite
                            gcc
                          ];
  };

  services = {
  };

}
