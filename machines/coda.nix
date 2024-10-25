{
  inputs,
  config,
  pkgs,
  lib,
  currentSystem,
  currentSystemUser,
  currentSystemName,
  ...
}: {
  imports = [
    ./hardware/coda.nix
    ../modules/nixos/desktop.nix
    ../modules/nixos/networking.nix
    ../modules/nixos/nix-ld.nix
    ../modules/nixos/virt
    # ../modules/nixos/secureboot.nix
    # ../modules/nixos/vscode-server.nix
  ];

  # services.secureboot.enable = true;

  nix = {
    enable = true;
    settings = {
      # keep-derivations = true;
      # keep-outputs = true;
      allowed-users = ["*"];
      auto-optimise-store = false;
      cores = 0;
      experimental-features = ["nix-command" "flakes"];
      extra-sandbox-paths = [];
      max-jobs = "auto";
      require-sigs = true;
      sandbox = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      system-features = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
      trusted-substituters = [];
      trusted-users = ["root" "jrizzo"];
    };
  };

  networking = {
    hostName = currentSystemName;
    # Disable the firewall since we're in a VM and we want to make it
    # easy to visit stuff in here. We only use NAT networking anyways.
    # firewall.enable = false;
    firewall.allowedTCPPorts = [22 443 631 3080 8443];
  };

  boot = {
    # Be careful updating this.
    # boot.kernelPackages = pkgs.linuxPackages_latest;
    # Use the systemd-boot EFI boot loader.
    supportedFilesystems = ["ntfs"];
    loader = {
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

  # Set your time zone.
  time.timeZone = "America/New_York";

  services = {
    # Don't forget to run the following to enable the service
    # systemctl --user enable auto-fix-vscode-server.service
    # systemctl --user start auto-fix-vscode-server.service
    # FIX: ln -sfT /run/current-system/etc/systemd/user/auto-fix-vscode-server.service ~/.config/systemd/user/auto-fix-vscode-server.service
    # vscode-server.enable = true;
    # vscode-server.enableFHS = true;
    printing.enable = true;
    colord.enable = true;
    hardware.bolt.enable = true;
    xserver.videoDrivers = ["nvidia"];
    ollama = {
      enable = false;
      acceleration = "cuda";
    };
    tabby = {
      enable = false;
      acceleration = "cuda";
      usageCollection = false;
    };
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
    # synergy.server = {
    #   enable = true;
    #   address = "0.0.0.0";
    #   autoStart = true;
    #   tls.enable = true;
    # };

    virt.enable = true;
    virt.preseed = {};
    # virt.preseed = {
    #   config = {
    #     "core.https_address" = ":8443";
    #   };
    #   networks = [
    #     {
    #       config = {
    #         "ipv4.address" = "10.10.10.1/24";
    #         "ipv4.nat" = "true";
    #       };
    #       name = "incusbr0";
    #       type = "bridge";
    #     }
    #   ];
    #   profiles = [
    #     {
    #       devices = {
    #         eth0 = {
    #           name = "eth0";
    #           network = "incusbr0";
    #           type = "nic";
    #         };
    #         root = {
    #           path = "/";
    #           pool = "default";
    #           size = "35GiB";
    #           type = "disk";
    #         };
    #       };
    #       name = "default";
    #     }
    #   ];
    #   storage_pools = [
    #     {
    #       config = {
    #         source = "/var/lib/incus/storage-pools/default";
    #       };
    #       driver = "dir";
    #       name = "default";
    #     }
    #   ];
    #   cluster = {
    #     server_name = currentSystemName;
    #     enabled = true;
    #   };
    # };
  };
  # security.apparmor.enable = true;

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      # nvidiaPersistenced = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    opengl = {
      enable = true; # in stable
      driSupport = true;
      driSupport32Bit = true;
    };
    # graphics.enable = true; # for unstable
    # graphics = {
    #   enable = true;
    #   enable32Bit = true;
    # };
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
    hackrf.enable = true;
    flipperzero.enable = true;
  };

  # Don't require password for sudo
  # security.sudo.wheelNeedsPassword = false;

  # Select internationalisation properties.
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    mutableUsers = false;
    users.root = {
      isSystemUser = true;
      hashedPassword = "$y$j9T$huQi//1srOgV4dSHFgVrh/$mZbJwRhMuqOTAPWssVxlL1d9YCjDxugoQejlN8I4K70";
    };
  };
  # nixpkgs.config.permittedInsecurePackages = [ ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment = {
    systemPackages = with pkgs; [
      cachix
      cudatoolkit
      devenv
      direnv
      git
      home-manager
      niv
      obsidian
      ollama
      tmux
      wget
      element-desktop-wayland
      jan
      # For hypervisors that support auto-resizing, this script forces it.
      # I've noticed not everyone listens to the udev events so this is a hack.
      (writeShellScriptBin "xrandr-auto" ''
        xrandr --output Virtual-1 --auto
      '')
    ];

    sessionVariables.NIXOS_OZONE_WL = "1";
  };

  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = false;
  # system.autoUpgrade.channel = "https://channels.nixos.org/nixos-24.05";
  system.stateVersion = "24.05"; # Did you read the comment?
}
