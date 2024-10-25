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
    ./hardware/irl.nix
    ../modules/nixos/networking.nix
    ../modules/nixos/nix-ld.nix
    ../modules/nixos/virt
    # ../modules/nixos/secureboot.nix
    # ../modules/nixos/vscode-server.nix
  ];

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
      substituters = ["https://cache.nixos.org/"];
      system-features = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
      trusted-substituters = [];
      trusted-users = ["root" "jrizzo"];
    };
  };

  users = {
    mutableUsers = false;
    users.root = {
      isSystemUser = true;
      initialHashedPassword = "$y$j9T$nF3bvV8Ta/mmPCELOr5hB/$jRPG1EZ0rPuCuzKdPgn0VsAsfTyZMiEkrVneqOr7ci0";
    };
  };

  networking = {
    hostName = currentSystemName;

    # 443 for web traffic
    # 631 for ?
    # 3080 for gns3
    # 5432 for postgresql
    # 8443 for nginx rev proxy
    firewall.allowedTCPPorts = [22 443 631 3080 8443];

    interfaces.enp36s0f0.useDHCP = lib.mkDefault true;
    interfaces.enp36s0f1.useDHCP = lib.mkDefault true;
    interfaces.wlp38s0.useDHCP = lib.mkDefault true;
  };

  boot.loader = {
    # Use the systemd-boot EFI boot loader.
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;

    # VMware, Parallels both only support this being 0 otherwise you see
    # "error switching console mode" on boot.
    systemd-boot.consoleMode = "0";
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

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

  # Host Specific Applications
  environment.systemPackages = with pkgs; [
    cachix
    devenv
    direnv
    git
    home-manager
    killall
    niv
    nixos-generators # various image generators
    ollama
    tmux
    vim
    wget
    clinfo
    # amdgpu_top
    # lact # amdgpu controller
  ];

  #######################################################################
  # Hardware configuration
  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    # amdgpu.opencl.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    opengl = {
      enable = true; # in stable
      driSupport = true;
      driSupport32Bit = true;
      # extraPackages = with pkgs; [
      #   rocmPackages.clr.icd
      # ];
    };
  };

  #############################################################################
  # List services that you want to enable:
  services = {
    hardware.bolt.enable = true;
    # services.secureboot.enable = true;

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

    tailscale.enable = true;

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    # Enable my virt setup
    # cat preseed.yml | sudo incus admin init --preseed
    # preseed.yml
    # cluster:
    #   enabled: true
    #   server_address: 192.168.2.125:8443
    #   cluster_token: eyJzZXJ2ZXJfbmFtZSI6ImNvZGEiLCJmaW5nZXJwcmludCI6ImI2NGI2NmQyYTBjNzU4Nzk4NDgxYTFiZjhhOTU1YmFhZjg3Mzk5M2U2MzNhMDcxZDkzZTFjNjUzZmIxZDU1MzkiLCJhZGRyZXNzZXMiOlsiaXJsOjg0NDMiXSwic2VjcmV0IjoiZGE1NjkzYjZmYmM5MzU1YzJlYzBiM2VjMTQ1NWNiOTMyNjM5ZmU2N2IyMWY5ODZiOTExYTlkYjJkOGQyZmQ0ZSIsImV4cGlyZXNfYXQiOiIyMDI0LTEwLTI0VDIyOjQwOjA1Ljg5ODc2MzIxNi0wNDowMCJ9
    virt = {
      enable = true;
      preseed = {};
      # preseed = {
      #   cluster = {
      #     enabled = true;
      #     server_address = "${currentSystemName}:8443";
      #     cluster_token = "eyJzZXJ2ZXJfbmFtZSI6ImlybCIsImZpbmdlcnByaW50IjoiZDhmYjJkNjllZWE5NDc5ZjQxMzNjZjZiNTVmMWViMmJkOTg4ZWI2Nzk0ZTcwMjY2ZTBhNzhkN2ZhZWI1MmNkYiIsImFkZHJlc3NlcyI6WyIxOTIuMTY4LjIuMTI1Ojg0NDMiXSwic2VjcmV0IjoiNmNlMTE5OTJjZDIyZjA3N2RjZGI1MTcxYzQ1YzE3ZWMxNGU0NWViMTA1OWMyZWZlZTZjNDcwZTYzMmI0OGViNCIsImV4cGlyZXNfYXQiOiIyMDI0LTEwLTI0VDE5OjAxOjQ3LjExOTIxMjIzLTA0OjAwIn0=";
      #   };
      # };
    };
  };

  # security.apparmor.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
