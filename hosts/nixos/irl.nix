{ config, pkgs, lib, ezModules, modulesPath, inputs, ... }: {  
  imports = lib.attrValues {
    inherit (ezModules)
      secureboot
      nix-ld
      vscode-server
      virt;
  } ++ [ 
    (modulesPath + "/installer/scan/not-detected.nix") 
    inputs.nix-bitcoin.nixosModules.default
  ];

  networking.hostName = "irl";
  #
  # 80/443 for web traffic
  # 3080 for gns3
  # 5432 for postgresql
  networking.firewall.allowedTCPPorts = [ 80 443 5432 8335 8334 8332 9735 4224 ];

  # Host Specific Applications
  environment.systemPackages = with pkgs; [ 
    nixos-generators # various image generators
  ];

  #############################################################################
  # List services that you want to enable:

  # TailScale
  services.tailscale.enable = true;

  # Gitlab
  # services.gitlab = {
  #   enable = true;
  #   databasePasswordFile = pkgs.writeText "dbPassword" "zgvcyfwsxzcwr85l";
  #   initialRootPasswordFile = pkgs.writeText "rootPassword" "dakqdvp4ovhksxer";
  #   secrets = {
  #     secretFile = pkgs.writeText "secret" "Aig5zaic";
  #     otpFile = pkgs.writeText "otpsecret" "Riew9mue";
  #     dbFile = pkgs.writeText "dbsecret" "we2quaeZ";
  #     jwsFile = pkgs.runCommand "oidcKeyBase" {} "${pkgs.openssl}/bin/openssl genrsa 2048 > $out";
  #   };
  # };

  # services.nginx = {
  #   enable = true;
  #   recommendedProxySettings = true;
  #   virtualHosts = {
  #     localhost = {
  #       locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
  #     };
  #     "irl.technobable.com" = {
  #       addSSL = true;
  #       enableACME = true;
  #       locations."/".proxyPass = "http://unix:/run/gitlab/gitlab-workhorse.socket";
  #     };
  #   };
  # };

  # security.acme = {
  #   acceptTerms = true;
  #   defaults.email = "johnrizzo1@gmail.com";
  # };

  # systemd.services.gitlab-backup.environment.BACKUP = "dump";

  # Bitcoin
  # Automatically generate all secrets required by services.
  # The secrets are stored in /etc/nix-bitcoin-secrets
  nix-bitcoin.generateSecrets = true;

  # Enable some services.
  # See ../configuration.nix for all available features.
  services.bitcoind.enable = true;
  services.clightning.enable = true;
  services.mempool.enable = true;

  # When using nix-bitcoin as part of a larger NixOS configuration, set the following to enable
  # interactive access to nix-bitcoin features (like bitcoin-cli) for your system's main user
  nix-bitcoin.operator = {
    enable = true;
    name = "jrizzo";
  };

  nix-bitcoin.nodeinfo.enable = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts = {
      localhost = {
        locations."/".proxyPass = "http://127.0.0.1:60845";
      };
    };
  };

  # If you use a custom nixpkgs version for evaluating your system
  # (instead of `nix-bitcoin.inputs.nixpkgs` like in this example),
  # consider setting `useVersionLockedPkgs = true` to use the exact pkgs
  # versions for nix-bitcoin services that are tested by nix-bitcoin.
  # The downsides are increased evaluation times and increased system
  # closure size.
  #
  # nix-bitcoin.useVersionLockedPkgs = true;

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
