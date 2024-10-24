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
      substituters = ["https://cache.nixos.org/"];
      system-features = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
      trusted-substituters = [];
      trusted-users = ["root" "jrizzo"];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.root = {
    isSystemUser = true;
    initialHashedPassword = "$y$j9T$nF3bvV8Ta/mmPCELOr5hB/$jRPG1EZ0rPuCuzKdPgn0VsAsfTyZMiEkrVneqOr7ci0";
  };

  networking.hostName = currentSystemName;

  # 80/443 for web traffic
  # 3080 for gns3
  # 5432 for postgresql
  networking.firewall.allowedTCPPorts = [80 443 5432 8335 8334 8332 9735 4224];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # VMware, Parallels both only support this being 0 otherwise you see
  # "error switching console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.hardware.bolt.enable = true;

  #############################################################################
  # List services that you want to enable:

  # services.secureboot.enable = true;

  # Enable Ollama
  ollama = {
    enable = true;
    # acceleration = "rocm";
  };

  # TailScale
  services.tailscale.enable = true;

  networking.interfaces.enp36s0f0.useDHCP = lib.mkDefault true;
  networking.interfaces.enp36s0f1.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp38s0.useDHCP = lib.mkDefault true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  # Enable my virt setup
  services.virt.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
