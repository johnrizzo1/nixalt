{ pkgs, ... }: {
  imports = [
    ./libvirt.nix
    ./lxd.nix
    #./podman.nix
    ./docker.nix
    ./incus.nix
    ./gns3.nix
    # ./proxmox.nix
  ];

  environment.systemPackages = with pkgs; [ bridge-utils ];
}