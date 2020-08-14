# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
      /home/cody/gtd/.attach/5e/fdb6b3-7908-4fad-b826-360b3b5e6643/systemd-pia-3.nix
    ];


  # Use the systemd-boot EFI boot loader.
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;

  nixpkgs.config.allowUnfree = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
  services.xserver.videoDrivers = [ "nvidia"];
  # steam 32 bit for things like rocket league
  hardware.opengl.driSupport32Bit = true;
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_11;
    dataDir = "/data/postgresql";
    authentication =  ''
    # Generated file; do not edit!
    # TYPE  DATABASE        USER            ADDRESS                 METHOD
    local   all             all                                     trust
    host    all             all             127.0.0.1/32            trust
    host    all             all             ::1/128                 trust
    '';
  };
  
  hardware.opengl.extraPackages = [
      pkgs.libGL_driver
      pkgs.linuxPackages.nvidia_x11.out
  ];
  hardware.bluetooth = {
    enable = true;
    config = { General = { Enable = "Source,Sink,Media,Socket"; }; };
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.extraHosts = ''
  #155.138.239.187 codygman.dev
  '';
  networking.networkmanager.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n = {
  #   consoleFont = "Lat2-Terminus16";
  #   consoleKeyMap = "us";
  #   defaultLocale = "en_US.UTF-8";
  # };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim steam chromium google-chrome retroarch
  ];

 nixpkgs.config.retroarch = {
  enableDolphin = true;
  enableMGBA = true;
  enableMAME = true;
};
 
 nixpkgs.config.chromium = {
    enableWideVine = true;
  };
 nixpkgs.config.google-chrome = {
    enableWideVine = true;
  };



  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
 programs.adb.enable = true;

 # TODO move to home-manager?
 programs.ssh.startAgent = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # TODO move to home-manager?
  services.openssh = {
    enable = true;
    ports = [22];
    permitRootLogin = "yes";
    passwordAuthentication = false;
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22000 ];
  networking.firewall.allowedUDPPorts = [ 21027 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio = {
    support32Bit = true;
    enable = true;
#     configFile = pkgs.writeText "default.pa" ''
#   load-module module-bluetooth-policy
#   load-module module-bluetooth-discover
#   ## module fails to load with 
#   ##   module-bluez5-device.c: Failed to get device path from module arguments
#   ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
#   # load-module module-bluez5-device
#   # load-module module-bluez5-discover
# '';
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };
  # hardware.pulseaudio = {
  #   # Sound config
  #   enable = true;
  #   package = pkgs.pulseaudioFull;
  #   extraModules = [ pkgs.pulseaudio-modules-bt ];

  #   support32Bit = true;
  # };

  # Enable the X11 windowing system.

  # Enable touchpad support.
  # services.xserver.libinput.enable = true;

  # services.xserver = {
  #   enable = true;
  #   layout = "us";
  #   xkbOptions = "ctrl:nocaps";
  #   config = "/home/cody/dotfiles/xmonad/xmonad.hs";
  #   windowManager.xmonad = {
  #     enable = true;
  #     enableContribAndExtras = true;
  #     extraPackages = haskellPackages: [
  #       haskellPackages.xmonad-contrib
  #       haskellPackages.xmonad-extras
  #       haskellPackages.xmonad
  #     ];
  #   };
  #   windowManager.default = "xmonad";
  # };
  

  services.xserver = {
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    enable = true;
    layout = "us";
    # xkbOptions = "ctrl:nocaps";
    windowManager.exwm = {
      enable = true;
      enableDefaultConfig = false;
    };
  };
  

  


  services.duplicati = {
    enable = true;
    user = "cody";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cody = {
    isNormalUser = true;
    extraGroups = [ "wheel" "adbusers" "audio" "sound" ]; # Enable ‘sudo’ for the user.
  };


  virtualisation.virtualbox.host.enable = true;  
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?

}
