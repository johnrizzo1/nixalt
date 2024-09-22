{ pkgs, ... }: {
  imports = [
    # ./libvirt.nix
    # ./lxd.nix
    #./podman.nix
    ./docker.nix
    # ./incus.nix
    ./gns3.nix
    # ./proxmox.nix
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
  };

  networking.nftables.enable = true;
  networking.firewall.trustedInterfaces = [ "incusbr0" ];

  programs.virt-manager.enable = true;
}