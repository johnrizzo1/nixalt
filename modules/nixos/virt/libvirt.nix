{ pkgs, lib, inputs, ... }: {
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
  };

  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
    spice-protocol
    virt-viewer
    virt-manager
    #virtio-win
    #win-spice
    gnome-boxes
  ];
  programs.virt-manager.enable = true;
}