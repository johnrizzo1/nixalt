{ inputs, pkgs, ... }: {
  environment.systemPackages = [
    pkgs.proxmove
    pkgs.terraform
    pkgs.terraform-providers.proxmox
  ];

  services.proxmox-ve.enable = true;
}
