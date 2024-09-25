{ inputs, config, pkgs, lib, currentSystem, currentSystemName,... }:

let
  # Turn this to true to use gnome instead of i3. This is a bit
  # of a hack, I just flip it on as I need to develop gnome stuff
  # for now.
  linuxGnome = true;
in {
  imports = [ 
    ./hardware/coda.nix
    ../modules/nixos/desktop.nix
    ../modules/nixos/networking.nix
    ../modules/nixos/virt
  ];

  # Be careful updating this.
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  nix = {
    package = pkgs.nixVersions.latest;
    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';

    # public binary cache that I use for all my derivations. You can keep
    # this, use your own, or toss it. Its typically safe to use a binary cache
    # since the data inside is checksummed.
    # settings = {
    #   substituters = ["https://mitchellh-nixos-config.cachix.org"];
    #   trusted-public-keys = ["mitchellh-nixos-config.cachix.org-1:bjEbXJyLrL1HZZHBbO4QALnI5faYZppzkU4D2s0G8RQ="];
    # };
  };

  # users.users.root = {
  #   isSystemUser = true;
  #   initialHashedPassword = "$y$j9T$/rtWlSDTxh6freq48xNP51$HcBAQ5J.VluIdc5vmzmrActXmRy3K4pKj.WbTBoQDt1";
  # };

  # services.proxmox-ve = { 
  #   enable = true;
  #   vms = {
  #     myvm1 = {
  #       vmid = 100;
  #       memory = 4096;
  #       cores = 4;
  #       sockets = 2;
  #       kvm = false;
  #       net = [
  #         {
  #           model = "virtio";
  #           bridge = "vmbr0";
  #         }
  #       ];
  #       scsi = [ { file = "local:16"; } ];
  #     };
  #     # myvm2 = {
  #     #   vmid = 101;
  #     #   memory = 8192;
  #     #   cores = 2;
  #     #   sockets = 2;
  #     #   scsi = [ { file = "local:32"; } ];
  #     # };
  #   };
  # };
  # networking.bridges.vmbr0.interfaces = [ "enp3s0" ];
  # networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;
  # systemd.network.networks."10-lan" = {
  #   matchConfig.Name = [ "enp3s0" ];
  #   networkConfig = {
  #     Bridge = "vmbr0";
  #   };
  # };

  # systemd.network.netdevs."vmbr0" = {
  #   netdevConfig = {
  #     Name = "vmbr0";
  #     Kind = "bridge";
  #   };
  # };

  # systemd.network.networks."10-lan-bridge" = {
  #   matchConfig.Name = "vmbr0";
  #   networkConfig = {
  #     IPv6AcceptRA = true;
  #     DHCP = "ipv4";
  #   };
  #   linkConfig.RequiredForOnline = "routable";
  # };

  # nixpkgs.config.permittedInsecurePackages = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # VMware, Parallels both only support this being 0 otherwise you see
  # "error switching console mode" on boot.
  boot.loader.systemd-boot.consoleMode = "0";

  # Define your hostname.
  networking.hostName = currentSystemName;

  # Set your time zone.
  time.timeZone = "America/New_York";

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.printing.enable = true;
  services.colord.enable = true;
  services.hardware.bolt.enable = true;

  # services.secureboot.enable = true;
  # services.hackrf.enable = true;

  # gate with test for desktop
  # hardware.graphics.enable = true;
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jrizzo";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
#   networking.useDHCP = false;

  # Don't require password for sudo
  security.sudo.wheelNeedsPassword = false;

  # Virtualization settings
#   virtualisation.docker.enable = true;

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

  # Enable tailscale. We manually authenticate when we want with
  # "sudo tailscale up". If you don't use tailscale, you should comment
  # out or delete all of this.
  services.tailscale.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    cachix
    devenv
    direnv
    git
    gnumake
    home-manager
    killall
    niv
    rxvt_unicode
    signal-desktop
    tmux
    vim
    weechat
    wget
    xclip
    vscodium

    # For hypervisors that support auto-resizing, this script forces it.
    # I've noticed not everyone listens to the udev events so this is a hack.
    (writeShellScriptBin "xrandr-auto" ''
      xrandr --output Virtual-1 --auto
    '')
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  # Disable the firewall since we're in a VM and we want to make it
  # easy to visit stuff in here. We only use NAT networking anyways.
#   networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
