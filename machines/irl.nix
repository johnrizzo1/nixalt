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
    ../modules/nixos/default.nix
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

    # K3s Kubernetes Distribution
    firewall = {
      allowedTCPPorts = [
        6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
        # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
        # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
      ];
      # allowedUDPPorts = [
        # 8472 # k3s, flannel: required if using multi-node for inter-node networking
      # ];
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

  nix.settings.cores = 24;

  # System Environment
  environment = {
    systemPackages =
      with pkgs; [
        _1password-cli
        # home-manager
        cachix
        clinfo
        unstable.devenv
        unstable.direnv
        dotnet-aspnetcore
        dotnet-sdk
        git
        killall
        nvidia-container-toolkit
        nil
        niv
        nixos-generators # various image generators
        ollama
        poetry
        python312
        python312Packages.pip
        rubyPackages.prettier
        tmux
        uv
        vim
        wget
      ];

    sessionVariables = {
      PODMAN_COMPOSE_WARNING_LOGS = "0"; # Disable podman-compose warning logs
    };
  };

  #######################################################################
  # Hardware configuration
  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    nvidia-container-toolkit.enable = true;
    nvidia-container-toolkit.mount-nvidia-executables = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    hackrf.enable = true;
    flipperzero.enable = true;
  };

  #######################################################################
  # List services that you want to enable:
  services = {
    hardware.bolt.enable = true;
    # services.secureboot.enable = true;
    xserver = {
      enable = false;
      videoDrivers = [ "nvidia" ];
    };

    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    displayManager.sddm.enable = false;
    # displayManager.cosmic-greeter.enable = true;
    # desktopManager.plasma6.enable = false;
    # desktopManager.cosmic.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    # pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;

      # use the example session manager (no others are packaged yet so this is enabled by default,
      # no need to redefine it in your config for now)
      #media-session.enable = true;
    };

    # Enable touchpad support (enabled default in most desktopManager).
    libinput.enable = true;

    vscode-server.enable = true;

    alloy.enable = true;

    # portainer = {
    #   enable = true; # Default false
    #   version = "latest";
    #   openFirewall = true; # Default false, set to 'true'
    #   port = 9443; # Sets the port number in both the firewall and
    #   # the docker container port mapping itself.
    # };

    # postgresql = {
    #   enable = true;
    #   ensureDatabases = [ 
    #     "litellm"
    #   ];
    #   enableTCPIP = true;
    #   # port = 5432;
    #   authentication = pkgs.lib.mkOverride 10 ''
    #     #type database DBuser origin-address auth-method
    #     local all      all                    trust
    #     host  all      all     127.0.0.1/32   trust
    #     host  all      jrizzo  0.0.0.0/0      scram-sha-256
    #     host  litellm  litellm 0.0.0.0/0      trust
    #   '';
    #   initialScript = pkgs.writeText "backend-initScript" ''
    #     CREATE ROLE jrizzo WITH PASSWORD 'wh4t3fr!' CREATEDB;
    #     CREATE ROLE litellm WITH LOGIN PASSWORD 'litellm' CREATEDB;
    #     CREATE DATABASE litellm;
    #     GRANT ALL PRIVILEGES ON DATABASE litellm TO litellm;
    #   '';
    # };

    k3s = {
      enable = true;
      role = "server";
    #  extraFlags = toString [
    #    # "--debug" # Optionally add additional args to k3s
    #  ];
    };

    #unbound = {
    #  enable = true;
    #  settings = {
    #    server = {
    #      # When only using Unbound as DNS, make sure to replace 127.0.0.1 with your ip address
    #      # When using Unbound in combination with pi-hole or Adguard, leave 127.0.0.1, and point Adguard to 127.0.0.1:PORT
    #      interface = [ "127.0.0.1" ];
    #      port = 5335;
    #      access-control = [ "127.0.0.1 allow" ];
    #      # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
    #      harden-glue = true;
    #      harden-dnssec-stripped = true;
    #      use-caps-for-id = false;
    #      prefetch = true;
    #      edns-buffer-size = 1232;
    #      # Custom settings
    #      hide-identity = true;
    #      hide-version = true;
    #    };
    #    forward-zone = [
    #      # Example config with quad9
    #      {
    #        name = ".";
    #        forward-addr = [
    #          "9.9.9.9#dns.quad9.net"
    #          "149.112.112.112#dns.quad9.net"
    #        ];
    #        forward-tls-upstream = true; # Protected DNS
    #      }
    #    ];
    #  };
    #};

    #adguardhome = {
    #  enable = true;
    #  openFirewall = true;
    #  # allowDHCP = true;
    #  mutableSettings = true;
    #  settings = {
    #    http = {
    #      # You can select any ip and port, just make sure to open firewalls where needed
    #      # address = "127.0.0.1:3003";
    #      address = "192.168.2.124:3003";
    #    };
    #    dns = {
    #      bind_hosts = [
    #        "127.0.0.1"
    #        "192.168.2.124"
    #      ];
    #      upstream_dns = [
    #        # Example config with quad9
    #        # "9.9.9.9#dns.quad9.net"
    #        # "149.112.112.112#dns.quad9.net"
    #        # Uncomment the following to use a local DNS service (e.g. Unbound)
    #        # Additionally replace the address & port as needed
    #        "127.0.0.1:5335"
    #      ];
    #    };
    #    filtering = {
    #      protection_enabled = true;
    #      filtering_enabled = true;
    #      parental_enabled = true; # Parental control-based DNS requests filtering.
    #      safe_search = {
    #        enabled = true; # Enforcing "Safe search" option for search engines, when possible.
    #      };
    #    };
    #    # The following notation uses map
    #    # to not have to manually create {enabled = true; url = "";} for every filter
    #    # This is, however, fully optional
    #    filters = map (url: { enabled = true; url = url; }) [
    #      "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt" # The Big List of Hacked Malware Web Sites
    #      "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt" # malicious url blocklist
    #    ];
    #  };
    #};

    # loki/grafana/prometheus setup
    # https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
    # loki = {
    #   enable = true;
    #   configFile = ../modules/common/files/loki.yaml;
    # };

    # grafana = {
    #   enable = true;
    #   settings = {
    #     server = {
    #       http_addr = "127.0.0.1";
    #       http_port = 2342;
    #       # enforce_domain = true;
    #       enable_gzip = true;
    #       domain = "grafana.technobable.com";
    #       # Alternatively, if you want to server Grafana from a subpath:
    #       # domain = "your.domain";
    #       # root_url = "https://your.domain/grafana/";
    #       # serve_from_sub_path = true;
    #     };
    #     # Prevents Grafana from phoning home     
    #     analytics.reporting_enabled = false;
    #   };
    # };


    # nginx = {
    #   enable = true;
    #   recommendedProxySettings = true;
    #   virtualHosts = {
    #     ${config.services.grafana.settings.server.domain} = {
    #       locations."/" = {
    #         proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
    #         proxyWebsockets = true;
    #         extraConfig =
    #           # required when target is also TLS server with multiple hosts
    #           # "proxy_ssl_server_name on; " +
    #           # required when the server wants to use HTTP Authentication
    #           "proxy_pass_header Authorization;";
    #       };
    #     };
    #   };
    # };

    # prometheus = {
    #   enable = true;
    #   globalConfig = {
    #     scrape_interval = "15s";
    #   };
    #   # For generating the data to scrape
    #   exporters = {
    #     node = {
    #       enable = true;
    #       enabledCollectors = [ "systemd" ];
    #       port = 9001;
    #       extraFlags = [
    #         "--collector.ethtool"
    #         "--collector.softirqs"
    #         "--collector.tcpstat"
    #         "--collector.wifi"
    #       ];
    #     };
    #   };
    #   scrapeConfigs = [
    #     {
    #       job_name = "irl";
    #       static_configs = [
    #         {
    #           targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
    #         }
    #       ];
    #     }
    #     {
    #       job_name = "incus";
    #       metrics_path = "/1.0/metrics";
    #       scheme = "http";
    #       static_configs = [
    #         {
    #           targets = [ "irl.technobable.com:8444" ];
    #         }
    #       ];
    #     }
    #   ];
    # };

    # promtail = {
    #   enable = true;
    #   configFile = ../modules/common/files/promtail.yaml;
    # };

    # ollama = {
      # enable = true;
      # acceleration = "cuda";
    # };

    # tabby = {
    # # Another AI Interface
    # enable = false;
    # acceleration = "cuda";
    # usageCollection = false;
    # };

    samba = {
      enable = true;
      securityType = "user";
      openFirewall = true;
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        #"use sendfile" = "yes";
        #"max protocol" = "smb2";
        # note: localhost is the ipv6 localhost ::1
        "hosts allow" = "192.168. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "downloads" = {
        "path" = "/mnt/data01/qbt/downloads";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0775";
      };
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
      # preseed = { };
    };
  };

  #######################################################################
  # Docker Services
  # environment.etc."containers/registries.conf".text = ''
  #   [registries.search]
  #   registries = ['docker.io']
  # '';
  # virtualisation.oci-containers = {
  #   backend = lib.mkForce "podman";
  #   containers = {
  #     portainer = {
  #       image = "portainer/portainer-ce:lts";
  #       autoStart = true;
  #       privileged = true;
  #       ports = [ 
  #         "8000:8000"
  #         "8443:9443"
  #       ];
  #       volumes = [
  #         "portainer_data:/data"
  #         "/var/run/docker.sock:/var/run/docker.sock"
  #       ];
  #     };
  #   };
  # };

  #######################################################################
  # OS Program Configuration
  programs = {
    _1password.enable = true;
  };

  #######################################################################
  # Security Configuration
  # security.apparmor.enable = true;
  security.rtkit.enable = true;

  #######################################################################
  # System Configuration
  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = false;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
  system.stateVersion = "24.05"; # Did you read the comment?
}
