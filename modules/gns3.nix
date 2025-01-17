{ pkgs
, config
, lib
, currentSystemUser
, ...
}:
{
  options.services.gns3 =
    {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable my gns3 stack";
      };
    };

  config = lib.mkIf config.services.virt.enable {
    environment.systemPackages = with pkgs; [
      gns3-gui
      gns3-server
      # kdePackages.krdc
      inetutils
    ];

    services.gns3-server = {
      enable = true;
      vpcs.enable = true;
      ubridge.enable = true;
      dynamips.enable = true;
      settings = {
        Server.ubridge_path = pkgs.lib.mkForce "/run/wrappers/bin/ubridge";
      };
    };

    users = {
      groups.gns3 = { };
      users = {
        ${currentSystemUser}.extraGroups = [ "gns3" ];
        gns3 = {
          group = "gns3";
          isSystemUser = true;
        };
      };
    };

    systemd.services.gns3-server.serviceConfig = {
      User = "gns3";
      DynamicUser = pkgs.lib.mkForce false;
      NoNewPrivileges = pkgs.lib.mkForce false;
      RestrictSUIDSGID = pkgs.lib.mkForce false;
      PrivateUsers = pkgs.lib.mkForce false;
      UMask = pkgs.lib.mkForce "0022";
      DeviceAllow =
        [
          "/dev/net/tun rw"
          "/dev/net/tap rw"
        ]
        ++ pkgs.lib.optionals config.virtualisation.libvirtd.enable [
          "/dev/kvm"
        ];
    };
  };
}
