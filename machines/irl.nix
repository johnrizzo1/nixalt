{ inputs
, config
, pkgs
, lib
, currentSystem
, currentSystemUser
, currentSystemName
, ...
}: {
  imports = [
    ./hardware/irl.nix
    ../modules/nixos
  ];

  users = {
    mutableUsers = false;
    users.root = {
      isSystemUser = true;
      initialHashedPassword = "$y$j9T$nF3bvV8Ta/mmPCELOr5hB/$jRPG1EZ0rPuCuzKdPgn0VsAsfTyZMiEkrVneqOr7ci0";
    };
  };

  networking = {
    hostName = currentSystemName;

    firewall.enable = lib.mkForce true;
    firewall.allowedTCPPorts = [ 22 443 631 3080 8443 ];

    interfaces = {
      enp36s0f0.useDHCP = lib.mkDefault true;
      enp36s0f1.useDHCP = lib.mkDefault true;
      wlp38s0.useDHCP = lib.mkDefault true;
    };
  };

  boot = {
    # Be careful updating this.
    # boot.kernelPackages = pkgs.linuxPackages_latest;
    # Use the systemd-boot EFI boot loader.
    supportedFilesystems = [ "ntfs" ];
    loader = {
      # Use the systemd-boot EFI boot loader.
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      # VMware, Parallels both only support this being 0 otherwise you see
      # "error switching console mode" on boot.
      systemd-boot.consoleMode = "0";
    };
    kernel.sysctl = {
      "vm.max_map_count" = 262144;
    };
  };

  time.timeZone = "America/New_York";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Host Specific Applications
  environment.systemPackages = with pkgs; [
    # amdgpu_top
    # lact # amdgpu controller
    cachix
    clinfo
    devenv
    direnv
    git
    home-manager
    killall
    niv
    nixos-generators # various image generators
    ollama
    tmux
    vim
    wget
  ];

  #######################################################################
  # Hardware configuration
  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  #######################################################################
  # List services that you want to enable:
  services = {
    hardware.bolt.enable = true;
    # services.secureboot.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
    ollama = {
      enable = false;
      acceleration = "cuda";
    };

    tabby = {
      # Another AI Interface
      enable = false;
      acceleration = "cuda";
      usageCollection = false;
    };

    # loki/grafana/prometheus setup
    # https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
    # loki = {
    #   enable = true;
    #   configFile = ''
    #   auth_enabled: false

    #   server:
    #     http_listen_port: 3100

    #   ingester:
    #     lifecycler:
    #       address: 0.0.0.0
    #       ring:
    #         kvstore:
    #           store: inmemory
    #         replication_factor: 1
    #       final_sleep: 0s
    #     chunk_idle_period: 1h       # Any chunk not receiving new logs in this time will be flushed
    #     max_chunk_age: 1h           # All chunks will be flushed when they hit this age, default is 1h
    #     chunk_target_size: 1048576  # Loki will attempt to build chunks up to 1.5MB, flushing first if chunk_idle_period or max_chunk_age is reached first
    #     chunk_retain_period: 30s    # Must be greater than index read cache TTL if using an index cache (Default index read cache TTL is 5m)
    #     max_transfer_retries: 0     # Chunk transfers disabled

    #   schema_config:
    #     configs:
    #       - from: 2020-10-24
    #         store: boltdb-shipper
    #         object_store: filesystem
    #         schema: v11
    #         index:
    #           prefix: index_
    #           period: 24h

    #   storage_config:
    #     boltdb_shipper:
    #       active_index_directory: /var/lib/loki/boltdb-shipper-active
    #       cache_location: /var/lib/loki/boltdb-shipper-cache
    #       cache_ttl: 24h         # Can be increased for faster performance over longer query periods, uses more disk space
    #       shared_store: filesystem
    #     filesystem:
    #       directory: /var/lib/loki/chunks

    #   limits_config:
    #     reject_old_samples: true
    #     reject_old_samples_max_age: 168h

    #   chunk_store_config:
    #     max_look_back_period: 0s

    #   table_manager:
    #     retention_deletes_enabled: false
    #     retention_period: 0s
    #   '';
    #   # configuration = {
    #   #   "auth_enabled" = false;
    #   #   "server" = {
    #   #     "http_listen_port" = 3100;
    #   #   };
    #   #   "common" = {
    #   #     "ring" = {
    #   #       "instance_addr" = "127.0.0.1";
    #   #       "kvstore" = {
    #   #         "store" = "inmemory";
    #   #       };
    #   #     };
    #   #     "replication_factor" = 1;
    #   #     "path_prefix" = "/tmp/loki";
    #   #   };
    #   #   "schema_config" = {
    #   #     "configs" = [
    #   #       {
    #   #         "from" = "2020-05-15";
    #   #         "store" = "tsdb";
    #   #         "object_store" = "filesystem";
    #   #         "schema" = "v13";
    #   #         "index" = {
    #   #           "prefix" = "index_";
    #   #           "period" = "24h";
    #   #         };
    #   #       }
    #   #     ];
    #   #   };
    #   #   "storage_config" = {
    #   #     "filesystem" = {
    #   #       "directory" = "/tmp/loki/chunks";
    #   #     };
    #   #   };
    #   # };
    # };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 3000;
          enforce_domain = true;
          enable_gzip = true;
          domain = "irl";

          # Alternatively, if you want to server Grafana from a subpath:
          # domain = "your.domain";
          # root_url = "https://your.domain/grafana/";
          # serve_from_sub_path = true;
        };

        # Prevents Grafana from phoning home     
        analytics.reporting_enabled = false;
      };
    };

    nginx.virtualHosts.${config.services.grafana.domain} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
        proxyWebsockets = true;
      };
    };

    # services.prometheus = {
    #   enable = true;
    #   port = 9001;

    #   # For generating the data to scrape
    #   exporters = {
    #     node = {
    #       enable = true;
    #       enabledCollectors = [ "systemd" ];
    #       port = 9002;
    #     };
    #   };

    #   scrapeConfigs = [{
    #     job_name = "chrysalis";
    #     static_configs = [{
    #       targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
    #     }];
    #   }];
    # };

    # promtail = {
    #   description = "Promtail service for Loki";
    #   wantedBy = [ "multi-user.target" ];

    #   serviceConfig = {
    #     ExecStart = ''
    #       ${pkgs.grafana-loki}/bin/promtail --config.file ${./files/irl/promtail.yaml}
    #     '';
    #   };
    # };

    tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      extraSetFlags = [ "--advertise-routes=10.45.209.0/24" ];
    };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    virt = {
      enable = true;
      preseed = { };
    };
  };

  #######################################################################
  # Security Configuration
  # security.apparmor.enable = true;

  #######################################################################
  # Systemd Configuration
  systemd.services.promtail = {
    description = "Promtail service for Loki";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.grafana-loki}/bin/promtail --config.file ${./promtail.yaml}
      '';
    };
  };

  #######################################################################
  # System Configuration
  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = false;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
  system.stateVersion = "24.05"; # Did you read the comment?
}
