{ config, pkgs, lib, modulesPath, inputs, ... }: {  
  imports = [
    ../modules/nixos/secureboot.nix
    ../modules/nixos/nix-ld.nix
    ../modules/nixos/vscode-server.nix
    ../modules/nixos/virt
    inputs.nix-bitcoin.nixosModules.default
  ];

  networking.hostName = "irl";

  # 80/443 for web traffic
  # 3080 for gns3
  # 5432 for postgresql
  networking.firewall.allowedTCPPorts = [ 80 443 5432 8335 8334 8332 9735 4224 ];

  # Host Specific Applications
  environment.systemPackages = with pkgs; [ 
    nixos-generators # various image generators
  ];

  #############################################################################
  # List services that you want to enable:

  services.secureboot.enable = true;
  
  # TailScale
  services.tailscale.enable = true;

  networking.interfaces.enp36s0f0.useDHCP = lib.mkDefault true;
  networking.interfaces.enp36s0f1.useDHCP = lib.mkDefault true;
  networking.interfaces.wlp38s0.useDHCP = lib.mkDefault true;
}
