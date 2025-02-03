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
    preseed = lib.mkOption {
      description = "Pre-seed to apply for incus setup";
      type = lib.types.attrs;
      default = { };
      example = {
        # config = {
        #   "core.https_address" = ":8443";
        # };
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
      };
    };
  };

  config = lib.mkIf config.services.hypervisor.enable {
    # networking.extraHosts = "192.168.2.132 coda coda.technobable.com";
    networking.firewall.trustedInterfaces = [ "incusbr0" ];
    networking.nftables.enable = true;

    # for portainer
    networking.firewall.allowedTCPPorts = [ 9443 8000 ];

    environment.systemPackages = with pkgs; [
      kubernetes
    ];

    virtualisation = {
      spiceUSBRedirection.enable = true;
      incus = {
        enable = true;
        package = pkgs.incus;
        ui.enable = true;
        inherit (config.services.hypervisor) preseed;
      };

      # podman = {
      #   enable = true;
      #   dockerSocket.enable = true;
      #   dockerCompat = true;
      #   # enableNvidia = true;
      #   autoPrune.enable = true;
      #   defaultNetwork.settings.dns_enabled = true;
      # };

      docker = {
        enable = true;
        enableOnBoot = true;
        # autoPrune = true;
      };

      oci-containers = {
        backend = "docker";
        # docker volume create portainer_data
        # docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.5
        containers = {
          # portainer = {
          #   hostname = "portainer";
          #   autoStart = true; 
          #   image = "portainer:latest";
          # };
        };
      };
    };

    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';

    hardware.nvidia-container-toolkit.enable = true;

    security.apparmor.enable = true;
  };
}
