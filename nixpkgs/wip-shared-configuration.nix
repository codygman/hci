{ config, pkgs, ... }:

# this is an attempt to use a single shared configuration.nix across 2 of my desktop nix machines and a laptop
# I had some weird issues with it last time I tried
# maybe it's a bad idea, maybe I just need to move to flakes :)
# leaving this hear in case I think it's a good idea

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./cachix.nix
      <home-manager/nixos> # TODO we should avoid using a channel and pin here
      # NOTE maybe see if https://github.com/ryantm/home-manager-template has anything I can use or if I should switch to it if applicable
    ];

  nixpkgs.config.allowUnfree = true;

  boot = {
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "nvidia" ];
    extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostName = "hci"; # I should make this machine specific.. maybe.. but while it's not why not call it hci :)
    networkmanager.enable = true;
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    useDHCP = false;

    # TODO I think these might be machine specific!
    # at least... when I used the one from my laptop on my desktop... I always failed to nixos-rebuild switch on some wireless error about ncsd
    interfaces.enp24s0.useDHCP = true;
    interfaces.wlp26s0.useDHCP = true;

    # Open ports in the firewall.
    firewall = {
      allowedTCPPorts = [ 22000 ];
      allowedUDPPorts = [ 21027 ];
    };
    # unused, but potentially useful later
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # Configure network proxy if necessary
    # proxy = {
    #   default = "http://user:password@proxy:port/";
    #   noProxy = "127.0.0.1,localhost,internal.domain";
    # };
  };

  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/Chicago";

  environment.systemPackages = with pkgs; [
    wget
  ];

  # List services that you want to enable:
  services = {
    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      layout = "us";
      # xkbOptions = "eurosign:e";
      # Enable touchpad support.
      libinput.enable = true;
      # Enable the KDE Desktop Environment.
      displayManager.sddm.enable = true;
      desktopManager.plasma5.enable = true;
      videoDrivers = [ "nvidia" ];
    };
    # Enable the OpenSSH daemon.
    # openssh.enable = true;
    # Enable CUPS to print documents.
    # printing.enable = true;

    openssh = {
      enable = false;
      ports = [22];
      permitRootLogin = "yes";
      passwordAuthentication = false;
    };

    duplicati = {
      enable = true;
      user = "cody";
    };

  };

  # Enable sound.
  sound = {
    enable = true;
  };

  hardware = {
    pulseaudio.enable = true;
    opengl = {
      extraPackages = [
            pkgs.libGL_driver
            pkgs.linuxPackages.nvidia_x11.out
      ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.cody = {
    isNormalUser = true;
    extraGroups = [ "wheel" "network-manager" "networkmanager" ]; # Enable ‘sudo’ for the user.
  };
  home-manager.users.cody = import ./home.nix;

  # virtualisation.virtualbox.host.enable = true;  

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs = {
  #   # mtr.enable = true;
  #   # gnupg.agent = { enable = true; enableSSHSupport = true; };
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.09"; # Did you read the comment?

}

