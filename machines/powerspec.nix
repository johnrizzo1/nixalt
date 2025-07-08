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

  # Host Specific Applications
  environment = {
    systemPackages = with pkgs; [
      _1password-cli
      _1password-gui
      # home-manager
      cachix
      clinfo
      unstable.devenv
      unstable.direnv
      dbeaver-bin
      dotnet-aspnetcore
      dotnet-sdk
      git
      google-chrome
      keymapp
      killall
      ktailctl
      nil
      niv
      nixos-generators # various image generators
      ollama
      poetry
      python312
      python312Packages.pip
      rubyPackages.prettier
      signal-desktop
      tmux
      uv
      vim
      vscode
      wget
    ];
    sessionVariables = {
      # NIXOS_OZONE_WL = "1"; # Enable Ozone Wayland
      # NIXOS_WAYLAND = "1";
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

    # virt = {
    # enable = true;
    # preseed = { };
    # };
  };

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
