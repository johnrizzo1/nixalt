# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ezModules, modulesPath, inputs, ... }:
{
  imports = lib.attrValues {
    inherit (ezModules)
      hackrf
      secureboot
      nix-ld
      # crypto
      desktop
      virt;
  } ++ [ 
    /etc/nixos/hardware-configuration.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  networking.hostName = "coda";

  environment.systemPackages = with pkgs; [
    signal-desktop
    weechat
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.printing.enable = true;
  services.colord.enable = true;
  services.hardware.bolt.enable = true;
  
  # services.secureboot.enable = true;
  services.hackrf.enable = true;

  # gate with test for desktop
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jrizzo";
  services.tailscale.enable = true;

  # This and the import should be in a separate file as it is generated
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
