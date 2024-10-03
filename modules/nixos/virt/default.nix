{ pkgs, ... }: {
  imports = [
    # ./libvirt.nix
    # ./lxd.nix
    # ./podman.nix
    # ./docker.nix
    # ./incus.nix
    ./gns3.nix
    ./proxmox.nix
  ];

  environment.systemPackages = with pkgs; [
    bridge-utils
    spice
    spice-gtk
    spice-protocol
    virt-viewer
    virt-manager
    #virtio-win
    #win-spice
    gnome-boxes
    qemu_full
    swtpm
    swtpm-tpm2
    OVMFFull
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
    # lxd = {
    #   enable = true;
    #   ui.enable = true;
    #   recommendedSysctlSettings = true;
    # };
    # lxc = {
    #   enable = true;
    #   lxcfs.enable = true;
    # };
    incus = {
      enable = true;
      ui.enable = true;
    };
    docker.enable = true;
  };

  networking.nftables.enable = true;
  # networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "incusbr0" "vmbr0" ]; # enp36s0f1

  programs.virt-manager.enable = true;

  services.proxmox-ve = { 
    vms = {
      myvm1 = {
        vmid = 100;
        memory = 4096;
        cores = 4;
        sockets = 2;
        kvm = false;
        net = [
          {
            model = "virtio";
            bridge = "vmbr0";
          }
        ];
        scsi = [ { file = "local:16"; } ];
      };
    };
  };

  networking.bridges.vmbr0.interfaces = [ "enp36s0f1" ];
  # networking.interfaces.vmbr0.useDHCP = lib.mkDefault true;
  # systemd.network.networks."10-lan" = {
  #   matchConfig.Name = [ "enp3s0" ];
  #   networkConfig = {
  #     Bridge = "vmbr0";
  #   };
  # };

  systemd.network.netdevs."vmbr0" = {
    netdevConfig = {
      Name = "vmbr0";
      Kind = "bridge";
    };
  };

  # systemd.network.networks."10-lan-bridge" = {
  #   matchConfig.Name = "vmbr0";
  #   networkConfig = {
  #     IPv6AcceptRA = true;
  #     DHCP = "ipv4";
  #   };
  #   linkConfig.RequiredForOnline = "routable";
  # };


}
