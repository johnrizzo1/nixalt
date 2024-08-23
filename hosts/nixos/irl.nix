{
  config,
  pkgs,
  lib,
  ezModules,
  ...
}: {  
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-linux";

  # Edit this configuration file to define what should be installed on
  # your system.  Help is available in the configuration.nix(5) man page
  # and in the NixOS manual (accessible by running ‘nixos-help’).

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
    # Include the results of the hardware scan.
    #   ./virtualization.nix

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-2aa9d68b-b33c-4e1b-a7f5-68f39b0c8e2c".device = "/dev/disk/by-uuid/2aa9d68b-b33c-4e1b-a7f5-68f39b0c8e2c";
  networking.hostName = "irl"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.home =
    if pkgs.stdenv.isDarwin
    then "/var/root"
    else "/root";

  users.users.jrizzo = {
    isNormalUser = true;
    description = "John Rizzo";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    git
    devenv
    direnv
    curl
    wget
  ];

  nix.settings.extra-experimental-features = "nix-command flakes";
  nix.settings.trusted-users = ["root" "@wheel"];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  services.tailscale.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ec665c2b-d6f5-4693-b3db-5646d109fe55";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-af2d5c42-e6ce-4117-b259-e9f896b7f24c".device = "/dev/disk/by-uuid/af2d5c42-e6ce-4117-b259-e9f896b7f24c";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4F68-0B16";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e7e3118f-c6d4-4b6a-aeca-1ba9d14e2128"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp36s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp36s0f1.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp38s0.useDHCP = lib.mkDefault true;

  # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
