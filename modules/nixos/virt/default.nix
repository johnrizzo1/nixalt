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
      swtpm-tpm2
      OVMFFull
      opentofu
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
      # containers.cdi.dynamic.nvidia.enable = true;
      incus = {
        enable = true;
        ui.enable = true;
        # preseed = {
        #   networks = [
        #     {
        #       config = {
        #         "ipv4.address" = "10.0.100.1/24";
        #         "ipv4.nat" = "true";
        #       };
        #       name = "incusbr0";
        #       type = "bridge";
        #     }
        #   ];
        #   profiles = [
        #     {
        #       devices = {
        #         eth0 = {
        #           name = "eth0";
        #           network = "incusbr0";
        #           type = "nic";
        #         };
        #         root = {
        #           path = "/";
        #           pool = "default";
        #           size = "35GiB";
        #           type = "disk";
        #         };
        #       };
        #       name = "default";
        #     }
        #   ];
        #   storage_pools = [
        #     {
        #       config = {
        #         source = "/var/lib/incus/storage-pools/default";
        #       };
        #       driver = "dir";
        #       name = "default";
        #     }
        #   ];
        # };
      };
    };

    # This is to support nvidia cards on docker
    hardware.nvidia-container-toolkit.enable = true;

    # Required for incus
    networking.nftables.enable = true;

    # networking.firewall.enable = true;
    # networking.firewall.trustedInterfaces = ["incusbr0"];

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
