# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  modulesPath,
  user_config,
  host_config,
  hostname,
  ...
}:
# let
#   _trusted-users = host_config.coda.nix.settings.trusted-users;
#   _allowedTCPPorts = host_config.coda.networking.firewall.allowedTCPPorts;
#   _allowedUDPPorts = host_config.coda.networking.firewall.allowedUDPPorts;
#   _hostname = host_config.coda.hostname;
# in 
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    (modulesPath + "/installer/scan/not-detected.nix")
    ./common/nixos
  ];

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  users.users.jrizzo = user_config.users.jrizzo // {shell = pkgs.zsh;};

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.xserver = {
    # Enable the X11 windowing system.
    # You can disable this if you're only using the Wayland session.
    enable = true;

    # Configure keymap in X11
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # The hardware-configuration.nix
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [
    "ahci"
    "nvme"
    "sd_mod"
    "thunderbolt"
    "usb_storage"
    "usbhid"
    "xhci_pci"
  ];
  boot.initrd.kernelModules = [];
  boot.initrd.luks.devices = {
    "luks-e8a4a0e3-34f0-4309-95ed-1d2aa8c8e872".device = 
      "/dev/disk/by-uuid/e8a4a0e3-34f0-4309-95ed-1d2aa8c8e872";
    "luks-85005d91-884a-4325-9d0a-357ae571dde6".device = 
      "/dev/disk/by-uuid/85005d91-884a-4325-9d0a-357ae571dde6";
  };
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  hardware.opengl.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  services.xserver.videoDrivers = [ "nvidia" ];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/15f0c4ae-b205-40c4-a7c6-86dc6601f0ac";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/06CC-08A9";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };
 
  swapDevices = [ { device = "/dev/disk/by-uuid/c37720bd-205a-47a4-8b82-ca2a9cad1ef6"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  # Set your system kind (needed for flakes)
  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
