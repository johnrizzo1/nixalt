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
#  let
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
  # hardware.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  #   # If you want to use JACK applications, uncomment this
  #   #jack.enable = true;

  #   # use the example session manager (no others are packaged yet so this is enabled by default,
  #   # no need to redefine it in your config for now)
  #   #media-session.enable = true;
  # };

  # services.xserver = {
  #   # Enable the X11 windowing system.
  #   # You can disable this if you're only using the Wayland session.
  #   enable = true;
  #   # Configure keymap in X11
  #   xkb.layout = "us";
  #   xkb.variant = "";
  # };

  # Enable the KDE Plasma Desktop Environment.
  # services.displayManager.sddm.enable = true;
  # services.desktopManager.plasma6.enable = true;
  
  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # The hardware-configuration.nix
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-amd"];
  boot.extraModulePackages = [];

  boot.initrd.luks.devices = {
    "luks-2aa9d68b-b33c-4e1b-a7f5-68f39b0c8e2c".device = 
      "/dev/disk/by-uuid/2aa9d68b-b33c-4e1b-a7f5-68f39b0c8e2c";

    "luks-af2d5c42-e6ce-4117-b259-e9f896b7f24c".device =
      "/dev/disk/by-uuid/af2d5c42-e6ce-4117-b259-e9f896b7f24c";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ec665c2b-d6f5-4693-b3db-5646d109fe55";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/4F68-0B16";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };
  };

  swapDevices = [ { device = "/dev/disk/by-uuid/e7e3118f-c6d4-4b6a-aeca-1ba9d14e2128"; } ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  # networking.useDHCP = lib.mkDefault true;
  networking.interfaces.enp36s0f0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp36s0f1.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp38s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
