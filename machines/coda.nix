{ inputs
, config
, pkgs
, lib
, currentSystemUser
, currentSystemName
, ...
}:
{
  imports = [
    ./hardware/coda.nix
    ./common/nixos.nix
  ];

  networking = {
    hostName = currentSystemName;

    networkmanager.enable = true;
    networkmanager.unmanaged = [
      "incusbr0"
      "virbr0"
      "docker0"
      "tailscale0"
    ];
    firewall.trustedInterfaces = [
      "incusbr0"
      "virbr0"
      "docker0"
    ];
    # Required for incus
    nftables.enable = true;

    firewall.enable = lib.mkForce true;
    firewall.allowedTCPPorts = [ 22 ];

    # interfaces = {
    #   enp3s0.useDHCP = lib.mkDefault true;
    # };
  };

  boot = {
    initrd.systemd.enable = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    plymouth.enable = true;
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
      # inputs.claude-desktop.packages.${pkgs.stdenv.system}.claude-desktop
      # kitty
      # smplayer
      # vscodium
      ##cudatoolkit
      ##jan
      alpaca # ollama GUI
      beeper
      calibre
      chromium
      discord
      element-desktop
      firefox
      freetube
      gimp
      gitkraken
      jetbrains-toolbox
      kdenlive
      keybase
      keybase-gui
      libreoffice
      lmstudio
      localstack
      niv
      obs-studio
      obsidian
      ollama
      R
      rstudio
      dotnet-sdk
      signal-desktop
      spotube
      synology-drive-client
      texliveFull
      tuba # fediverse client
      vlc
      vscode
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
    secureboot.enable = true;
    printing.enable = true;
    colord.enable = true;
    xserver.videoDrivers = [ "nvidia" ];

    ollama = {
      enable = true;
      acceleration = "cuda";
    };

    open-webui = {
      enable = false;
    };

    # 
    # X/Wayland Config
    #- yubikey-agent.enable = true;
    displayManager.autoLogin.enable = true;
    displayManager.autoLogin.user = currentSystemUser;

    # Enable tailscale. We manually authenticate when we want with
    # "sudo tailscale up". If you don't use tailscale, you should comment
    # out or delete all of this.
    tailscale.enable = true;
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

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = false;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
  # system.stateVersion = "24.05"; # Did you read the comment?
}
