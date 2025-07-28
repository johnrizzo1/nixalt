{ input
, config
, pkgs
, lib
, currentSystemUser
, currentSystemName
, ...
}: {
  imports = [
    ./hardware/powerspec.nix
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
    systemPackages = with pkgs; [
      _1password-cli
      _1password-gui
      # home-manager
      airspy
      avahi
      # beekeeper-studio
      beeper
      cachix
      clinfo
      dbeaver-bin
      element-desktop
      gimp3-with-plugins
      gnuradio
      google-chrome
      gqrx
      hackrf
      kdePackages.alpaka
      kdePackages.dragon
      kdePackages.filelight
      kdePackages.kcalc
      kdePackages.kdenlive
      kdePackages.krdc
      kdePackages.partitionmanager
      keymapp
      ktailctl
      lens
      lmstudio
      obs-studio
      obsidian
      ollama
      orca-slicer
      rtl-sdr
      redisinsight
      redis
      signal-desktop
      synology-drive-client
      unstable.devenv
      unstable.direnv
      vscode
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
    keyboard.zsa.enable = true;
  };

  #######################################################################
  # List services that you want to enable:
  services = {
    hardware.bolt.enable = true;
    # services.secureboot.enable = true;
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";
        options = "ctrl:nocaps"; # Disable Caps Lock
      };
    };

    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;

    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable sound with pipewire.
    pulseaudio.enable = false;
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

    virt.enable = true;
    
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

    # postgresql = {
    #   enable = true;
    #   ensureDatabases = [ 
    #     "litellm"
    #   ];
    #   enableTCPIP = true;
    #   # port = 5432;
    #   authentication = pkgs.lib.mkOverride 10 ''
    #     #type database DBuser origin-address auth-method
    #     local all      all     trust
    #     # host  all      all     127.0.0.1/32   trust
    #     host  all      jrizzo  127.0.0.1/32   trust
    #   '';
    #   initialScript = pkgs.writeText "backend-initScript" ''
    #     CREATE ROLE jrizzo WITH PASSWORD 'wh4t3fr' CREATEDB;
    #     CREATE ROLE litellm WITH LOGIN PASSWORD 'litellm' CREATEDB;
    #     CREATE DATABASE litellm;
    #     GRANT ALL PRIVILEGES ON DATABASE litellm TO litellm;
    #   '';
    # };

    # litellm = {
    #   enable = true;
    #   openFirewall = true;
    #   host = "0.0.0.0";
    #   package = pkgs.unstable.litellm;
    #   settings = {
    #     environment_variables = {
    #       LITELLM_MASTER_KEY = "wh4t3fr";
    #       LITELLM_SALT_KEY = "sk-wh4t3fr";
    #       DATABASE_URL = "postgresql://litellm:litellm@localhost/litellm";
    #       # PORT = "4000";
    #       STORE_MODEL_IN_DB = "true";
    #     };
    #   };
    # };
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
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ "jrizzo" ];
    };
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
