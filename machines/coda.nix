{ inputs
, config
, pkgs
, lib
, currentSystem
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

    interfaces = {
      enp3s0.useDHCP = lib.mkDefault true;
    };
  };

  boot = {
    # Be careful updating this.
    # boot.kernelPackages = pkgs.linuxPackages_latest;
    # Use the systemd-boot EFI boot loader.
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot = {
        enable = true;
        # VMware, Parallels both only support this being 0 otherwise you see
        # "error switching console mode" on boot.
        consoleMode = "0";
        # Copy EDK2 Shell to boot partition
        extraFiles."efi/shell.efi" = "${pkgs.edk2-uefi-shell}/shell.efi";
        extraEntries = {
          "windows.conf" =
            let
              boot-drive = "FS1";
            in
            ''
              title Windows Bootloader
              efi /efi/shell.efi
              options - nointerrupt -nomap -noversion ${boot-drive}:EFI\Microsoft\Boot\Bootmgfw.efi 
              sort-key y_windows
            '';

          "edk2-uefi-shell.conf" = ''
            title EDK2 UEFI Shell
            efi /efi/shell.efi
            sort-key z_edk2
          '';
        };
      };

      efi.canTouchEfiVariables = true;

      # efi.efiSysMountPoint = "/boot"; # not sure about this
    };
    kernel.sysctl = {
      "vm.max_map_count" = 262144;
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
      alpaca # ollama GUI
      cachix
      cudatoolkit
      devenv
      direnv
      element-desktop
      git
      gitkraken
      # home-manager
      jan
      jetbrains.pycharm-community
      keybase
      keybase-gui
      libreoffice
      niv
      obs-studio
      obsidian
      ollama
      tmux
      wget

      _1password-gui
      chromium
      discord
      element-desktop-wayland
      firefox
      freetube
      signal-desktop
      # smplayer
      vlc
      kdenlive
      spotube
      synology-drive-client
      vscodium
      kitty

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
      package = config.boot.kernelPackages.nvidiaPackages.stable;
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
    hardware.bolt.enable = true;
    secureboot.enable = true;
    printing.enable = true;
    colord.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
    ollama = {
      enable = false;
      acceleration = "cuda";
    };
    tabby = {
      enable = false;
      acceleration = "cuda";
      usageCollection = false;
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
    keybase.enable = true;
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    # services.secureboot.enable = true;

    virt = {
      enable = false;
      # preseed = { };
    };

    vscode-server.enable = true;
  };

  # security.apparmor.enable = true;

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = false;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
  system.stateVersion = "24.05"; # Did you read the comment?
}
