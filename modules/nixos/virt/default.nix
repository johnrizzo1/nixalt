{ pkgs
, lib
, config
, inputs
, ...
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
    # incus_over_lxd = lib.mkOption {
    #   type = lib.types.bool;
    #   default = false;
    #   example = true;
    #   description = "Enable incus over lxd";
    # };
    preseed = lib.mkOption {
      description = "Pre-seed to apply for incus setup";
      type = lib.types.attrs;
      default = { };
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
    users.users.jrizzo.extraGroups = [ "incus-admin" ];
    environment.systemPackages = with pkgs; [
      docker-compose
      bridge-utils
      spice
      spice-gtk
      spice-protocol
      virt-viewer
      virt-manager
      gnome-boxes
      podman-desktop
      kubectl
      kind
      qemu_full
      quickemu
      swtpm
      # swtpm-tpm2
      OVMFFull
      opentofu
      ovn
    ];

    virtualisation = {
      # vswitch.enable = true;
      libvirtd = {
        enable = true;
        allowedBridges = [ "virbr0" ];
        qemu = {
          package = pkgs.qemu_kvm;
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [ pkgs.OVMFFull.fd ];
        };
      };
      spiceUSBRedirection.enable = true;
      # containers.cdi.dynamic.nvidia.enable = true;
      # incus = lib.mkIf config.services.virt.incus_over_lxd {
      #   enable = true;
      #   package = pkgs.incus;
      #   ui.enable = true;
      #   inherit (config.services.virt) preseed;
      # };
      # lxd = lib.mkIf (! config.services.virt.incus_over_lxd) {
      lxd = {
        enable = true;
        # package = pkgs.lxd-lts;
        ui.enable = true;
        recommendedSysctlSettings = true;
        # inherit (config.services.virt) preseed;
      };
      # docker = {
      #   enable = true;
      #   enableOnBoot = true;
      # };
      podman = {
        enable = true;
        dockerSocket.enable = true;
        dockerCompat = true;
        # enableNvidia = true;
        autoPrune.enable = true;
      };
    };

    # This is to support nvidia cards on docker
    # enable this after you create an option for cuda/rocm
    # --device=nvidia.com/gpu=all
    hardware.nvidia-container-toolkit.enable = true;

    programs.virt-manager.enable = true;

    networking = {
      # Required for incus
      nftables.enable = true;

      # project: default
      # name: incusbr0
      # description: ''
      # type: bridge
      # config:
      #   bridge.driver: openvswitch
      #   dns.domain: technobable.com
      #   dns.search: tail577f.ts.net, technobable.com
      #   ipv4.address: 10.159.34.1/24
      #   ipv4.nat: 'true'
      #   ipv6.address: none

      # networking.vswitches = {
      #   "ovsbr0" = {
      #     interfaces = { }
      #   }
      # };

      # networking.firewall.enable = true;
      networkmanager.unmanaged = [
        "incusbr0"
        "virbr0"
        "docker0"
        "tailscale0"
      ];
      firewall.trustedInterfaces = [
        "incusbr0"
        "virbr0"
        "docker0"
      ];
      # "tailscale0"

      # networking.bridges.vmbr0.interfaces = [ "enp36s0" ];
      # networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;
    };
  };
}
