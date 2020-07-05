{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  # Let Home Manager install and manage itself.
  programs = {
    # uncomment these to let nix manager you bash, zsh, or fish shell and make integrations wor
    #zsh.enable = true;
    #bash.enable = true;
    #fish.enable = true;
    git.enable = true;
    home-manager.enable = true;
    direnv = {
      enable = true;
      enableZshIntegration = true; # these integrations only work if you use the nix installed zsh or bash respectively
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    vscode = {
      enable = true;
      # These might not work outside of NixOS sadly
      # This should be seen on non-NixOS as a list of extensions
      # to install
      extensions = with pkgs.vscode-extensions; [
          # digitalassetholdingsllc.ghcide # not in nixpkgs
          # arrterian.nix-env-selector # not in nixpkgs (surprisingly)
          # make looking at nix files nicer
          bbenoist.Nix
      ];
    };
  };

  home = {
    packages = with pkgs; [ ripgrep cachix ];
  };

  services = {
    lorri = {
      enable = true;
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "$USER";
  home.homeDirectory = "/home/$USER";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
