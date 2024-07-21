{ hostname, host_config, lib, pkgs, config, ...}: let
  _trusted-users = host_config.${hostname}.nix.settings.trusted-users;
  _allowedTCPPorts = host_config.${hostname}.networking.firewall.allowedTCPPorts;
  _allowedUDPPorts = host_config.${hostname}.networking.firewall.allowedUDPPorts;
in {
  imports = [
    ../nix.nix
    ../nixpkgs.nix
    ../environment.nix
    ../nixpkgs-fmt.nix
  ];

  nix.settings.trusted-users = _trusted-users;
  nix.settings.extra-experimental-features = "nix-command flakes";

  # Enable networking
  networking = {
    hostName = hostname;
    firewall = {
      allowedTCPPorts = _allowedTCPPorts;
      allowedUDPPorts = _allowedUDPPorts;
      enable = lib.mkDefault true;
    };
    networkmanager.enable = lib.mkDefault true;
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Set your time zone.
  time.timeZone = host_config.${hostname}.time.timeZone;

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

  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;
  environment.systemPackages = with pkgs; [
    wget
    vim
    curl
    home-manager
    direnv
    zsh
  ];

  # Required for wayland support for vscode
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # This setups a SSH server. Very important if you're setting up a headless system.
  # Feel free to remove if you don't need it.
  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = "no";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = false;
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  # Set your system kind (needed for flakes)
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
