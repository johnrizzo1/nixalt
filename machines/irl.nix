{ inputs, config, pkgs, lib, 
  currentSystem, currentSystemUser, currentSystemName,
  ... }:
  
{  
  imports = [
    ./hardware/irl.nix
    ../modules/nixos/networking.nix
    ../modules/nixos/nix-ld.nix
    ../modules/nixos/virt
    # ../modules/nixos/secureboot.nix
    # ../modules/nixos/vscode-server.nix
  ];

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  networking.hostName = currentSystemName;

  # 80/443 for web traffic
  # 3080 for gns3
  # 5432 for postgresql
  networking.firewall.allowedTCPPorts = [ 80 443 5432 8335 8334 8332 9735 4224 ];

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
  
  users.mutableUsers = false;
  
  # Host Specific Applications
  environment.systemPackages = with pkgs; [ 
    nixos-generators # various image generators
    cachix
    devenv
    direnv
    git
    gnumake
    home-manager
    killall
    niv
    tmux
    vim
    weechat
    wget
  ];
  
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.hardware.bolt.enable = true;

  #############################################################################
  # List services that you want to enable:

  # services.secureboot.enable = true;

  # TailScale
  services.tailscale.enable = true;

  networking.interfaces.enp36s0f0.useDHCP = lib.mkDefault true;
  networking.interfaces.enp36s0f1.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp38s0.useDHCP = lib.mkDefault true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  system.stateVersion = "24.05"; # Did you read the comment?
}
