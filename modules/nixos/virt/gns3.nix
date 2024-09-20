{ pkgs, config, ... }: {
  environment.systemPackages = with pkgs; [
    gns3-gui
    gns3-server
    kdePackages.krdc
    inetutils
  ];

  services.gns3-server.enable = true;
  services.gns3-server.vpcs.enable = true;
  services.gns3-server.ubridge.enable = true;
  services.gns3-server.dynamips.enable = true;

  services.gns3-server.settings = {
    Server.ubridge_path = pkgs.lib.mkForce "/run/wrappers/bin/ubridge";
  };
  users.groups.gns3 = {};
  users.users.gns3 = {
    group = "gns3";
    isSystemUser = true;
  };
  systemd.services.gns3-server.serviceConfig = {
    User = "gns3";
    DynamicUser = pkgs.lib.mkForce false;
    NoNewPrivileges = pkgs.lib.mkForce false;
    RestrictSUIDSGID = pkgs.lib.mkForce false;
    PrivateUsers = pkgs.lib.mkForce false;
    UMask = pkgs.lib.mkForce "0022";
    DeviceAllow = [
      "/dev/net/tun rw"
      "/dev/net/tap rw"
    ] ++ pkgs.lib.optionals config.virtualisation.libvirtd.enable [
      "/dev/kvm"
    ];
  };

  # 3080 is gns3
  networking.firewall.allowedTCPPorts = [ 3080 ];
}