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
      # obs-studio
      obsidian
      ollama
      R
      rstudio
      dotnet-sdk
      signal-desktop
      spotube
      synology-drive-client
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
    # This is to support nvidia cards on docker
    # enable this after you create an option for cuda/rocm
    # --device=nvidia.com/gpu=all
    nvidia-container-toolkit.enable = true;
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
      enable = false;
      acceleration = "cuda";
    };

    # flatpak.enable = true;

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
    hypervisor.enable = true;
    virt-client.enable = true;
    vscode-server.enable = true;
    # comfyui = {
      # enable = true;
      # package = pkgs.comfyui-nvidia;
      # host = "0.0.0.0";
      # models = builtins.attrValues pkgs.nixified-ai.models;
      # customNodes = with inputs.comfyui.pkgs; [
      #   comfyui-gguf
      #   comfyui-impact-pack
      # ];
      # openFirewall = true;
    # };

    samba = {
      enable = false;
      openFirewall = true;
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "tymnet";
          "netbios name" = "tymnet";
          "security" = "user";
          #"use sendfile" = "yes";
          #"max protocol" = "smb2";
          # note: localhost is the ipv6 localhost ::1
          "hosts allow" = "192.168.0. 127.0.0.1 localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };
        # "public" = {
        #   "path" = "/home/jrizzo";
        #   "browseable" = "yes";
        #   "read only" = "no";
        #   "guest ok" = "yes";
        #   "create mask" = "0644";
        #   "directory mask" = "0755";
        #   "force user" = "jrizzo";
        #   "force group" = "jrizzo";
        # };
        # "private" = {
        #   "path" = "/mnt/Shares/Private";
        #   "browseable" = "yes";
        #   "read only" = "no";
        #   "guest ok" = "no";
        #   "create mask" = "0644";
        #   "directory mask" = "0755";
        #   "force user" = "username";
        #   "force group" = "groupname";
        # };
      };
    };

    samba-wsdd = {
      enable = false;
      openFirewall = true;
    };
  };

  # security.apparmor.enable = true;

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = false;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
  # system.stateVersion = "24.05"; # Did you read the comment?
}
