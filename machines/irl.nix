{
  input,
  config,
  pkgs,
  lib,
  currentSystem,
  currentSystemUser,
  currentSystemName,
  ...
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
    domain = "technobable.com";
    # dhcpcd.enable = false;
    networkmanager.enable = true;

    firewall = {
      enable = lib.mkForce false;
      allowedTCPPorts = [22 53 80 443 631 3000 3100 3080 5380 8443 9001 9090 9095];
      allowedUDPPorts = [53 67];
    };

    interfaces = {
      enp36s0f0.useDHCP = lib.mkDefault true;
      enp36s0f1 = {
        # useDHCP = lib.mkDefault false;
        ipv4.addresses = [
          {
            address = "192.168.2.124";
            prefixLength = 24;
          }
        ];
      };
      wlp38s0.useDHCP = lib.mkDefault true;
    };
    defaultGateway = "192.168.2.1";
    nameservers = ["192.168.2.124"];
  };

  # systemd.network.networks.enp36s0f1 = {
  #   name = "enp36s0f1";
  #   enable = true;
  #   dns = [ "127.0.0.1" ];
  #   address = [ "192.168.2.124" ];
  #   routes = [ { routeConfig = { Gateway = "192.168.2.1"; }; } ];
  #   networkConfig = {
  #   	Ipv6AcceptRA = "no";
  #   };
  # };

  boot = {
    # Be careful updating this.
    # boot.kernelPackages = pkgs.linuxPackages_latest;
    # Use the systemd-boot EFI boot loader.
    supportedFilesystems = ["ntfs"];
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
    xserver.videoDrivers = ["nvidia"];
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

    # rsyslog = {
    #   enable = true;
    #
    # };

    # loki/grafana/prometheus setup
    # https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
    loki = {
      enable = true;
      configFile = ./files/irl/loki-local-config.yaml;
    };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 2342;
          #     enforce_domain = true;
          #     enable_gzip = true;
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

    nginx = {
      # https://wiki.nixos.org/wiki/Nginx
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        ${config.services.grafana.settings.server.domain} = {
          locations."/" = {
            proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
            proxyWebsockets = true;
            extraConfig =
              # required when target is also TLS server with multiple hosts
              # "proxy_ssl_server_name on;" +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
          };
        };
      };
    };

    technitium-dns-server = {
      enable = false;
      openFirewall = true;
    };

    adguardhome = {
      enable = false;
      openFirewall = true;
      allowDHCP = true;
      settings = {
        http = {address = "0.0.0.0:3000";};
        dns = {upstream_dns = ["8.8.8.8" "4.4.4.4"];};
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;

          parental_enabled = false;
          safe_search = {
            enabled = false;
          };
        };
        filters =
          map
          (url: {
            inherit url;
            enabled = true;
          }) [
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
            "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
          ];
      };
    };

    prometheus = {
      enable = true;

      globalConfig = {
        scrape_interval = "15s";
      };

      # For generating the data to scrape
      exporters = {
        node = {
          enable = true;
          enabledCollectors = ["systemd"];
          port = 9001;
          extraFlags = [
            "--collector.ethtool"
            "--collector.softirqs"
            "--collector.tcpstat"
            "--collector.wifi"
          ];
        };
      };

      scrapeConfigs = [
        {
          job_name = "irl";
          static_configs = [
            {
              targets = ["127.0.0.1:${toString config.services.prometheus.exporters.node.port}"];
            }
          ];
        }
        {
          job_name = "incus";
          metrics_path = "/1.0/metrics";
          scheme = "http";
          static_configs = [
            {
              targets = ["irl.technobable.com:8444"];
            }
          ];
        }
      ];
    };

    promtail = {
      enable = true;
      extraFlags = [
        "--config.file=${./files/irl/promtail.yaml}"
      ];
      # configuration = ./files/irl/promtail.yaml;
    };

    tailscale = {
      enable = true;
      # useRoutingFeatures = "server";
      # extraSetFlags = [ "--advertise-routes=10.45.209.0/24" ];
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
      preseed = {};
    };
  };

  #######################################################################
  # Security Configuration
  # security.apparmor.enable = true;

  #######################################################################
  # System Configuration
  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = false;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
  system.stateVersion = "24.05"; # Did you read the comment?
}
