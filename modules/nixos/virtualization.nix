{ pkgs, lib, inputs, ... }: {
  imports = [
    inputs.proxmox-nixos.nixosModules.proxmox-ve
  ];

  services.proxmox-ve.enable = true;
}