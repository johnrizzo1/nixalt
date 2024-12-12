{ pkgs, lib, inputs, config, ... }: {
  imports = [ inputs.determinate.nixosModules.default ];

  networking.hostName = "monitor";
  boot.loader.grub.enable = lib.mkDefault true; # Use the boot drive for GRUB
  boot.loader.grub.devices = [ "nodev" ];

  nix.settings.trusted-users = [ "root" "@wheel" ]; # Allow remote updates
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users = {
    mutableUsers = false;
    users = {
      root = {
        isSystemUser = true;
        initialHashedPassword = "$y$j9T$nF3bvV8Ta/mmPCELOr5hB/$jRPG1EZ0rPuCuzKdPgn0VsAsfTyZMiEkrVneqOr7ci0";
      };
      osuser = {
        isNormalUser = true;
        initialHashedPassword = "$y$j9T$nF3bvV8Ta/mmPCELOr5hB/$jRPG1EZ0rPuCuzKdPgn0VsAsfTyZMiEkrVneqOr7ci0";
        extraGroups = [
          "users"
          "wheel"
        ];
      };
    };
  };

  services = {
    qemuGuest.enable = true;

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
          domain = "monitor";

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
      configFile = ../common/files/promtail.yaml;
    };
  };

  system.stateVersion = "24.05";
}

