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

}