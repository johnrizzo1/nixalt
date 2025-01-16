{ inputs
, config
, pkgs
, lib
  # , currentSystem
, currentSystemUser
, currentSystemName
, ...
}:
{
  imports = [
    ./hardware/coda.nix
    ../modules/nixos
    ../modules/nixos/desktop.nix
  ];

  users = {
    mutableUsers = false;
    users.root = {
      isSystemUser = true;
      hashedPassword = "$y$j9T$huQi//1srOgV4dSHFgVrh/$mZbJwRhMuqOTAPWssVxlL1d9YCjDxugoQejlN8I4K70";
    };
  };

  networking = {
    hostName = currentSystemName;

    networkmanager.enable = true;

    firewall.enable = lib.mkForce true;
    firewall.allowedTCPPorts = [
      22
      443
      631
      3080
      3389
      8080
      8443
    ];

    # interfaces = {
    #   enp3s0.useDHCP = lib.mkDefault true;
    # };
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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
  environment = {
    systemPackages = with pkgs; [

      _1password-gui
      # home-manager
      # kitty
      # smplayer
      # vscodium
      ##cudatoolkit
      ##jan
      alpaca # ollama GUI
      beeper
      cachix
      calibre
      chromium
      devenv
      direnv
      discord
      element-desktop
      firefox
      freetube
      gimp
      git
      gitkraken
      # inputs.claude-desktop.packages.${pkgs.stdenv.system}.claude-desktop
      kdenlive
      keybase
      keybase-gui
      localstack
      libreoffice
      lmstudio
      niv
      obs-studio
      obsidian
      ollama
      signal-desktop
      spotube
      synology-drive-client
      tmux
      tuba # fediverse client
      vlc
      vscode
      wget
      zoom-us

      # For hypervisors that support auto-resizing, this script forces it.
      # I've noticed not everyone listens to the udev events so this is a hack.
      (writeShellScriptBin "xrandr-auto" ''
        xrandr --output Virtual-1 --auto
      '')
    ];

    sessionVariables.NIXOS_OZONE_WL = "1";
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
      open = false;
      nvidiaSettings = true;
      # nvidiaPersistenced = true;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
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
  };

  #######################################################################
  # List services that you want to enable:
  services = {
    desktop.enable = true;
    hardware.bolt.enable = true;
    # secureboot.enable = true;
    printing.enable = true;
    colord.enable = true;
    xserver.videoDrivers = [ "nvidia" ];

    ollama = {
      enable = false;
      acceleration = "cuda";
    };

    flatpak.enable = true;

    ##tabby = {
    ##  enable = false;
    ##  acceleration = "cuda";
    ##  usageCollection = false;
    ##};

    # https://www.timescale.com/blog/postgresql-as-a-vector-database-create-store-and-query-openai-embeddings-with-pgvector/
    ##postgresql = {
    ##  enable = true;
    ##  ensureDatabases = [ "n8n" "jrizzo" ];
    ##  ensureUsers = [
    ##    {
    ##      name = "jrizzo";
    ##      ensureDBOwnership = true;
    ##      ensureClauses = {
    ##        superuser = true;
    ##        createrole = true;
    ##        createdb = true;
    ##      };
    ##    }
    ##  ];
    ##};

    # n8n.enable = false;
    # n8n.openFirewall = true;

    # 
    # X/Wayland Config
    #- yubikey-agent.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = currentSystemUser;

    # Enable tailscale. We manually authenticate when we want with
    # "sudo tailscale up". If you don't use tailscale, you should comment
    # out or delete all of this.
    tailscale.enable = true;
    ##keybase.enable = true;
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
    virt.enable = true;
    vscode-server.enable = true;
  };

  # security.apparmor.enable = true;

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = false;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
  system.stateVersion = "24.05"; # Did you read the comment?
}
