{ pkgs, config, lib, currentSystemName, ... }: {
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

  time.timeZone = "America/New_York";

  users = {
    mutableUsers = false;
  };

  networking = {
    hostName = currentSystemName;
    domain = "technobable.com";
    search = [ "technobable.com" "warthog-trout.ts.net" ];
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
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
      "tailscale0"
    ];
    # Required for incus
    nftables.enable = true;

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = pkgs.lib.mkDefault true;
    # interfaces.enp3s0.useDHCP = lib.mkDefault true;
    # interfaces.wlo1.useDHCP = lib.mkDefault true;

    firewall = {
      # Open ports in the firewall.
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      enable = true;
      allowPing = true;
    };
  };


  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      silent = true;
    };
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      syntaxHighlighting.enable = true;
    };
    tmux = {
      enable = true;
    };
  };

  services = {
    xserver.xkb.options = "ctrl:swapcaps";
    promtail = {
      enable = true;
      configFile = ./files/promtail.yaml;
    };
  };

  system.stateVersion = "24.11";
}
