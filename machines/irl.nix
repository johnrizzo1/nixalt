{ input
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
    # ../modules/nixos/monitor.nix
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
      allowedTCPPorts = [ 22 53 80 443 631 3000 3100 3080 5380 8443 9001 9090 9095 ];
      allowedUDPPorts = [ 53 67 ];
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
    nameservers = [ "192.168.2.124" ];
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
    cachix
    clinfo
    devenv
    direnv
    git
    # home-manager
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

    unbound = {
      enable = true;
      settings = {
        server = {
          # When only using Unbound as DNS, make sure to replace 127.0.0.1 with your ip address
          # When using Unbound in combination with pi-hole or Adguard, leave 127.0.0.1, and point Adguard to 127.0.0.1:PORT
          interface = [ "127.0.0.1" ];
          port = 5335;
          access-control = [ "127.0.0.1 allow" ];
          # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
          harden-glue = true;
          harden-dnssec-stripped = true;
          use-caps-for-id = false;
          prefetch = true;
          edns-buffer-size = 1232;

          # Custom settings
          hide-identity = true;
          hide-version = true;
        };
        forward-zone = [
          # Example config with quad9
          {
            name = ".";
            forward-addr = [
              "9.9.9.9#dns.quad9.net"
              "149.112.112.112#dns.quad9.net"
            ];
            forward-tls-upstream = true;  # Protected DNS
          }
        ];
      };
    };

    adguardhome = {
      enable = true;
      openFirewall = true;
      # allowDHCP = true;
      mutuableSettings = true;
      settings = {
        http = {
          # You can select any ip and port, just make sure to open firewalls where needed
          # address = "127.0.0.1:3003";
          address = "192.168.2.124:3003";
        };
        dns = {
          bind_hosts = [ 
            "192.168.2.124"
          ];
          upstream_dns = [
            # Example config with quad9
            # "9.9.9.9#dns.quad9.net"
            # "149.112.112.112#dns.quad9.net"
            # Uncomment the following to use a local DNS service (e.g. Unbound)
            # Additionally replace the address & port as needed
            "127.0.0.1:5335"
          ];
        };
        filtering = {
          protection_enabled = true;
          filtering_enabled = true;

          parental_enabled = true;  # Parental control-based DNS requests filtering.
          safe_search = {
            enabled = true;  # Enforcing "Safe search" option for search engines, when possible.
          };
        };
        # The following notation uses map
        # to not have to manually create {enabled = true; url = "";} for every filter
        # This is, however, fully optional
        filters = map(url: { enabled = true; url = url; }) [
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
        ];
      };
    };

    # loki/grafana/prometheus setup
    # https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
    # loki = {
    #   enable = true;
    #   configFile = ../common/files/loki.yaml;
    # };

    grafana = {
      enable = true;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 2342;
          # enforce_domain = true;
          enable_gzip = true;
          domain = "grafana.technobable.com";

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
      enable = true;
      recommendedProxySettings = true;
      virtualHosts = {
        ${config.services.grafana.domain} = {
          locations."/" = {
            proxyPass = "http://${toString config.services.grafana.settings.http_addr}:${toString config.services.grafana.settings.http_port}";
            proxyWebsockets = true;
            extraConfig =
              # required when target is also TLS server with multiple hosts
              # "proxy_ssl_server_name on; " +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
          };
        };
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
          enabledCollectors = [ "systemd" ];
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
              targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        }
        {
          job_name = "incus";
          metrics_path = "/1.0/metrics";
          scheme = "http";
          static_configs = [
            {
              targets = [ "irl.technobable.com:8444" ];
            }
          ];
        }
      ];
    };

    promtail = {
      enable = true;
      configFile = ../modules/common/files/promtail.yaml;
    };

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
      preseed = { };
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
