{ config, pkgs, lib, ezModules, modulesPath, ... }: {  
  imports = lib.attrValues {
    inherit (ezModules)
      secureboot
      nix-ld
      vscode-server
      virt;
  } ++ [ (modulesPath + "/installer/scan/not-detected.nix") ];
    # Include the results of the hardware scan.
    #   ./virtualization.nix

  networking.hostName = "irl";

  #############################################################################
  # List services that you want to enable:

  # TailScale
  services.tailscale.enable = true;

  # Gitlab
  services.gitlab = {
    enable = true;
    databasePasswordFile = pkgs.writeText "dbPassword" "zgvcyfwsxzcwr85l";
    initialRootPasswordFile = pkgs.writeText "rootPassword" "dakqdvp4ovhksxer";
    secrets = {
      secretFile = pkgs.writeText "secret" "Aig5zaic";
      otpFile = pkgs.writeText "otpsecret" "Riew9mue";
      dbFile = pkgs.writeText "dbsecret" "we2quaeZ";
      jwsFile = pkgs.runCommand "oidcKeyBase" {} "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      localhost = {
        locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
      };
    };
  };

  systemd.services.gitlab-backup.environment.BACKUP = "dump";

  # Enable Secure Boot on this host
  services.secureboot.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/ec665c2b-d6f5-4693-b3db-5646d109fe55";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-af2d5c42-e6ce-4117-b259-e9f896b7f24c".device = "/dev/disk/by-uuid/af2d5c42-e6ce-4117-b259-e9f896b7f24c";
  boot.initrd.luks.devices."luks-2aa9d68b-b33c-4e1b-a7f5-68f39b0c8e2c".device = "/dev/disk/by-uuid/2aa9d68b-b33c-4e1b-a7f5-68f39b0c8e2c";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4F68-0B16";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/e7e3118f-c6d4-4b6a-aeca-1ba9d14e2128"; }
    ];

  networking.interfaces.enp36s0f0.useDHCP = lib.mkDefault true;
  networking.interfaces.enp36s0f1.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp38s0.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
