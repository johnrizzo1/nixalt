{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    # inputs.proxmox-nixos.nixosModules.proxmox-ve
    # ./libvirt.nix
    # ./lxd.nix
    # ./podman.nix
    # ./docker.nix
    # ./incus.nix
    # ./gns3.nix
    # ./proxmox.nix
  ];

  options.services.virt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable my virtualisation stack";
    };
  };

  config = lib.mkIf config.services.virt.enable {
    environment.systemPackages = with pkgs; [
      bridge-utils
      spice
      spice-gtk
      spice-protocol
      virt-viewer
      virt-manager
      #virtio-win
      #win-spice
      # gnome-boxes
      qemu_full
      quickemu
      swtpm
      swtpm-tpm2
      OVMFFull
      # docker-compose
      # podman
      # podman-compose
      # podman-tui
      # podman-desktop
      # proxmove
      # terraform
      # terraform-providers.proxmox
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [pkgs.OVMFFull.fd];
        };
      };
      spiceUSBRedirection.enable = true;
      # lxd = {
      #   enable = true;
      #   ui.enable = true;
      #   recommendedSysctlSettings = true;
      # };
      # lxc = {
      #   enable = true;
      #   lxcfs.enable = true;
      # };
      incus = {
        enable = true;
        ui.enable = true;
        preseed = {
          networks = [
            {
              config = {
                "ipv4.address" = "10.0.100.1/24";
                "ipv4.nat" = "true";
              };
              name = "incusbr0";
              type = "bridge";
            }
          ];
          profiles = [
            {
              devices = {
                eth0 = {
                  name = "eth0";
                  network = "incusbr0";
                  type = "nic";
                };
                root = {
                  path = "/";
                  pool = "default";
                  size = "35GiB";
                  type = "disk";
                };
              };
              name = "default";
            }
          ];
          storage_pools = [
            {
              config = {
                source = "/var/lib/incus/storage-pools/default";
              };
              driver = "dir";
              name = "default";
            }
          ];
        };
      };
      # docker = {
      #   enable = true;
      #   enableOnBoot = true;
      # };
      # podman = {
      # enable = true;
      # dockerSocket.enable = true;
      # dockerCompat = true;
      # defaultNetwork.settings.dns_enabled = true;
      # };
      # containers.cdi.dynamic.nvidia.enable = true;
    };

    # This is to support nvidia cards on docker
    hardware.nvidia-container-toolkit.enable = true;

    # Required for incus
    networking.nftables.enable = true;

    networking.firewall.enable = true;
    networking.firewall.trustedInterfaces = ["incusbr0"];

    programs.virt-manager.enable = true;

    # services.proxmox-ve = {
    #   enable = true;
    #   vms = {
    #     myvm1 = {
    #       vmid = 100;
    #       memory = 4096;
    #       cores = 4;
    #       sockets = 2;
    #       kvm = false;
    #       net = [
    #         {
    #           model = "virtio";
    #           bridge = "vmbr0";
    #         }
    #       ];
    #       scsi = [ { file = "local:16"; } ];
    #     };
    #   };
    # };

    # networking.bridges.vmbr0.interfaces = [ "enp36s0" ];
    # networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;
    # systemd.network.networks."10-lan" = {
    #   matchConfig.Name = [ "enp3s0" ];
    #   networkConfig = {
    #     Bridge = "vmbr0";
    #   };
    # };

    # systemd.network.netdevs."vmbr0" = {
    #   netdevConfig = {
    #     Name = "vmbr0";
    #     Kind = "bridge";
    #   };
    # };

    # systemd.network.networks."10-lan-bridge" = {
    #   matchConfig.Name = "vmbr0";
    #   networkConfig = {
    #     IPv6AcceptRA = true;
    #     DHCP = "ipv4";
    #   };
    #   linkConfig.RequiredForOnline = "routable";
    # };
  };
}
