{ input
, config
, pkgs
, lib
, currentSystemUser
, currentSystemName
, ...
}: {
  imports = [
    ./hardware/irl.nix
    ./common/nixos.nix
  ];

  networking = {
    firewall = {
      allowedTCPPorts = [ 53 80 443 631 3000 3100 3101 3202 3080 4000 4001 5380 8443 9001 9090 9095 ];
      allowedUDPPorts = [ 53 67 ];
    };

    nat = {
      enable = true;
      internalInterfaces = [ "ve-+" ];
      externalInterface = "ens36s0f1";
      # Lazy IPv6 connectivity for the container
      # enableIPv6 = true;
    };

    interfaces = {
      # enp36s0f0.useDHCP = lib.mkDefault true;
      enp36s0f1 = {
        useDHCP = lib.mkDefault false;
        ipv4.addresses = [{ address = "192.168.2.124"; prefixLength = 24; }];
      };
      # wlp38s0.useDHCP = lib.mkDefault true;
    };
    defaultGateway = "192.168.2.1";
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
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
    # kernel.sysctl = {
    #   "vm.max_map_count" = 262144;
    # };
  };

  # Host Specific Applications
  environment.systemPackages = with pkgs; [
    clinfo
    nixos-generators # various image generators
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
    secureboot.enable = true;
    xserver.videoDrivers = [ "nvidia" ];

    unbound = {
      enable = false;
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
            forward-tls-upstream = true; # Protected DNS
          }
        ];
      };
    };

    adguardhome = {
      enable = false;
      openFirewall = true;
      # allowDHCP = true;
      mutableSettings = true;
      port = 3200;
      settings = {
        http = {
          # You can select any ip and port, just make sure to open firewalls where needed
          # address = "127.0.0.1:3003";
          address = "192.168.2.124:3003";
        };
        dns = {
          bind_hosts = [
            "127.0.0.1"
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
          parental_enabled = true; # Parental control-based DNS requests filtering.
          safe_search = {
            enabled = true; # Enforcing "Safe search" option for search engines, when possible.
          };
        };
        # The following notation uses map
        # to not have to manually create {enabled = true; url = "";} for every filter
        # This is, however, fully optional
        filters = map (url: { enabled = true; url = url; }) [
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
          "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
        ];
      };
    };

    postgresql = {
      enable = true;

      ensureUsers = [
	{
          name = "jrizzo";
          ensureDBOwnership = true;
	  ensureClauses = {
	    superuser = true;
	    createrole = true;
	    createdb = true;
   	  };
        }
      ];
      ensureDatabases = [ "jrizzo" "somedb" ];

      enableTCPIP = true;
      extensions = (ps: with ps; [
        postgis
        pgvector
        timescaledb
      ]);

      authentication = pkgs.lib.mkOverride 10 ''
        #type	database  DBuser  	source		auth-method
        local	all	all				trust
	host	all	all		127.0.0.1/32	trust
	host	all	all		::1/128		trust
	host	all	jrizzo		0.0.0.0/0	md5
	host	all	super		0.0.0.0/0	reject
      '';

      initialScript = pkgs.writeText "backend-initScript" ''
	CREATE EXTENSION IF NOT EXISTS vector;
	CREATE EXTENSION IF NOT EXISTS timescaledb;
      '';

      settings.shared_preload_libraries = [
	"timescaledb"
      ];
    };

    # loki/grafana/prometheus setup
    # https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
    loki = {
      enable = false;
      configFile = ../common/files/loki.yaml;
    };

    grafana = {
      enable = false;
      settings = {
        server = {
          http_addr = "127.0.0.1";
          http_port = 2342;
          # enforce_domain = true;
          enable_gzip = true;
          domain = "grafana.technobable.com";

          # Alternatively, if you want to server Grafana from a subpath:
          root_url = "https://grafana.technobable.com/grafana/";
          serve_from_sub_path = true;
        };

        # Prevents Grafana from phoning home     
        analytics.reporting_enabled = false;
      };
    };

    nginx = {
      enable = false;
      recommendedProxySettings = true;
      virtualHosts = {
        ${config.services.grafana.settings.server.domain} = {
          locations."/grafana" = {
            proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
            proxyWebsockets = true;
            extraConfig =
              # required when target is also TLS server with multiple hosts
              "proxy_ssl_server_name on; " +
              # required when the server wants to use HTTP Authentication
              "proxy_pass_header Authorization;";
          };
        };
      };
    };

    prometheus = {
      enable = false;

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
        # {
        # job_name = "incus";
        # metrics_path = "/1.0/metrics";
        # scheme = "http";
        # static_configs = [
        # {
        # targets = [ "irl.technobable.com:8444" ];
        # }
        # ];
        # }
      ];
    };

    promtail = {
      enable = true;
      configFile = ./files/promtail.yaml;
    };

    ollama = {
      enable = true;
      acceleration = "cuda";
      host = "0.0.0.0";
    };

    open-webui = {
      enable = false;
      openFirewall = true;
      host = "0.0.0.0";
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
      # extraSetFlags = [
      # "--advertise-routes=10.61.175.0/24,192.168.2.0/24,192.168.3.0/24,192.168.5.0/24" 
      # "--exit-node-allow-lan-access"
      # "--advertise-exit-node"
      # ];
    };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    hypervisor.enable = true;
    virt-client.enable = true;
    vscode-server.enable = true;
  };

  #######################################################################
  # System Configuration
  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = false;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
  # system.stateVersion = "24.05"; # Did you read the comment?
}
