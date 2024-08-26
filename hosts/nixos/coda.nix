# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ezModules, modulesPath, ... }:
{
  imports = lib.attrValues {
    inherit (ezModules) virt;
  } ++ [ (modulesPath + "/installer/scan/not-detected.nix") ];
  # imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostName = "coda"; # Define your hostname.

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.printing.enable = true;
  services.colord.enable = true;
  services.hardware.bolt.enable = true;

  # gate with test for desktop
  hardware.opengl.enable = true;
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

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/6714e7a5-59a5-47e3-a12a-9d1b221e4d32";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-92495b6b-c802-4e9b-a664-7ff01a612079".device = "/dev/disk/by-uuid/92495b6b-c802-4e9b-a664-7ff01a612079";
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/E78E-9520";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e8421a9d-d432-4a67-b6a9-b872e6644240"; }
    ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
