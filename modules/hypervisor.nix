{ pkgs
, lib
, config
, inputs
, currentSystemUser
, ...
}: {
  # imports = [
  #   ./gns3.nix
  # ];

  options.services.hypervisor = {
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

  config = lib.mkIf config.services.hypervisor.enable {
    # networking.extraHosts = "${kubeMasterIP} ${kubeMasterHostname}";
    networking.extraHosts = "192.168.2.132 coda coda.technobable.com";
    networking.firewall.trustedInterfaces = [ "incusbr0" ];

    environment.systemPackages = with pkgs; [
      kubernetes
    ];

    # services.kubernetes = {
    #   roles = ["master" "node"];
    #   masterAddress = "coda.technobable.com";
    #   apiserverAddress = "https://192.168.2.132:6443";
    #   easyCerts = true;
    #   apiserver = {
    #     enable = true;
    #     securePort = 6443;
    #     advertiseAddress = "192.168.2.132";
    #   };

    #   # use coredns
    #   addons.dns.enable = true;

    #   # needed if you use swap
    #   kubelet.extraOpts = "--fail-swap-on=false";
    # };

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
      containers.cdi.dynamic.nvidia.enable = true;
      # incus = lib.mkIf config.services.virt.incus_over_lxd {
      incus = {
        enable = true;
        package = pkgs.incus;
        ui.enable = true;
        inherit (config.services.hypervisor) preseed;
      };
      # lxd = lib.mkIf (! config.services.virt.incus_over_lxd) {
      # lxd = {
        # enable = true;
        # package = pkgs.lxd-lts;
        # ui.enable = true;
        # recommendedSysctlSettings = true;
        # inherit (config.services.virt) preseed;
      # };
      docker = {
        enable = true;
        enableOnBoot = true;
      };
      # podman = {
      #   enable = true;
      #   dockerSocket.enable = true;
      #   dockerCompat = true;
      #   # enableNvidia = true;
      #   autoPrune.enable = true;
      # };
    };

    # This is to support nvidia cards on docker
    # enable this after you create an option for cuda/rocm
    hardware.nvidia-container-toolkit.enable = true;
    # --device=nvidia.com/gpu=all
  };
}
