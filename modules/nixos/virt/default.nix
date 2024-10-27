{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  imports = [
    # ./gns3.nix
  ];

  options.services.virt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable my virtualisation stack";
    };
    preseed = lib.mkOption {
      description = "Pre-seed to apply for incus setup";
      type = lib.types.attrs;
      default = null;
      example = {
        config = {
          "core.https_address" = ":8443";
        };
        networks = [
          {
            config = {
              "ipv4.address" = "10.10.10.1/24";
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
        cluster = {
          server_name = "coda";
          enabled = true;
        };
      };
    };
  };

  config = lib.mkIf config.services.virt.enable {
    users.users.jrizzo.extraGroups = ["incus-admin"];
    environment.systemPackages = with pkgs; [
      bridge-utils
      spice
      spice-gtk
      spice-protocol
      virt-viewer
      virt-manager
      # gnome-boxes
      qemu_full
      quickemu
      swtpm
      # swtpm-tpm2
      OVMFFull
      opentofu
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
        allowedBridges = ["virbr0"];
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [pkgs.OVMFFull.fd];
        };
      };
      spiceUSBRedirection.enable = true;
      # containers.cdi.dynamic.nvidia.enable = true;
      incus = {
        enable = true;
        package = pkgs.incus;
        ui.enable = true;
        preseed = config.services.virt.preseed;
      };
      docker = {
        enable = true;
        # daemon.settings=  {
        #   userland-proxy = false;
        #   experimental = true;
        #   metrics-addr = "0.0.0.0:9323";
        #   ipv6 = true;
        #   fixed-cidr-v6 = "fd00::/80";
        # };
      };
    };

    # This is to support nvidia cards on docker
    # enable this after you create an option for cuda/rocm
    # --device=nvidia.com/gpu=all
    hardware.nvidia-container-toolkit.enable = true;

    # Required for incus
    networking.nftables.enable = true;

    # networking.firewall.enable = true;
    networking.firewall.trustedInterfaces = ["incusbr0" "virbr0"];

    programs.virt-manager.enable = true;

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
