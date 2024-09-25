{ inputs, pkgs, ... }: {
  imports = [
    inputs.proxmox-nixos.nixosModules.proxmox-ve
  ];

  environment.systemPackages = [
    pkgs.proxmove
    pkgs.terraform
    pkgs.terraform-providers.proxmox
  ];

  services.proxmox-ve.enable = true;
}