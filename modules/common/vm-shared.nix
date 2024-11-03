{ config
, pkgs
, lib
, currentSystem
, currentSystemName
, ...
}:
{
  # Be careful updating this.
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    # Use the systemd-boot EFI boot loader.
    loader = {
      efi.canTouchEfiVariables = true;

      # VMware, Parallels both only support this being 0 otherwise you see
      # "error switching console mode" on boot.
      systemd-boot = {
        enable = true;
        consoleMode = "0";
      };
    };
  };

  nix = {
    enable = true;
    settings = {
      # keep-derivations = true;
      # keep-outputs = true;
      allowed-users = [ "*" ];
      auto-optimise-store = false;
      cores = 0;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-sandbox-paths = [ ];
      max-jobs = "auto";
      require-sigs = true;
      sandbox = true;
      substituters = [ "https://cache.nixos.org/" ];
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      trusted-substituters = [ ];
      trusted-users = [
        "root"
        "jrizzo"
      ];
    };
  };

  nixpkgs.config.permittedInsecurePackages = [
    # Needed for k2pdfopt 2.53.
    "mupdf-1.17.0"
  ];

  networking = {
    # Define your hostname.
    hostName = "dev";

    # Disable the firewall since we're in a VM and we want to make it
    # easy to visit stuff in here. We only use NAT networking anyways.
    firewall.enable = false;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
  };

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Virtualization settings
  virtualisation.docker.enable = true;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-chinese-addons
      ];
    };
  };

  services = {
    # setup windowing environment
    # xserver =
    #   if linuxGnome
    #   then {
    #     enable = true;
    #     xkb.layout = "us";
    #     desktopManager.gnome.enable = true;
    #     displayManager.gdm.enable = true;
    #   }
    #   else {
    #     enable = true;
    #     xkb.layout = "us";
    #     dpi = 220;

    #     desktopManager = {
    #       xterm.enable = false;
    #       wallpaper.mode = "fill";
    #     };

    #     displayManager = {
    #       defaultSession = "none+i3";
    #       lightdm.enable = true;

    #       # AARCH64: For now, on Apple Silicon, we must manually set the
    #       # display resolution. This is a known issue with VMware Fusion.
    #       sessionCommands = ''
    #         ${pkgs.xorg.xset}/bin/xset r rate 200 40
    #       '';
    #     };

    #     windowManager = {
    #       i3.enable = true;
    #     };
    #   };

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
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

  # Manage fonts. We pull these from a secret directory since most of these
  # fonts require a purchase.
  fonts = {
    fontDir.enable = true;

    packages = [
      pkgs.fira-code
      pkgs.jetbrains-mono
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    with pkgs;
    [
      cachix
      gnumake
      killall
      niv
      # rxvt_unicode
      xclip

      # For hypervisors that support auto-resizing, this script forces it.
      # I've noticed not everyone listens to the udev events so this is a hack.
      (writeShellScriptBin "xrandr-auto" ''
        xrandr --output Virtual-1 --auto
      '')
    ]
    ++ lib.optionals (currentSystemName == "vm-aarch64") [
      # This is needed for the vmware user tools clipboard to work.
      # You can test if you don't need this by deleting this and seeing
      # if the clipboard sill works.
      gtkmm3
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
