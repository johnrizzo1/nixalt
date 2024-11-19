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
