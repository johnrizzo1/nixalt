{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gns3-gui
    kdePackages.krdc
    inetutils
  ];

  services.gns3-server.enable = true;
  services.gns3-server.vpcs.enable = true;
  services.gns3-server.ubridge.enable = true;
  services.gns3-server.dynamips.enable = true;
}