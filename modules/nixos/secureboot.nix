{ config
, pkgs
, inputs
, lib
, ...
}:
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  options.services.secureboot = {
    # enable = lib.mkEnableOption "secure boot";
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enable secure boot?";
    };
  };

  config = lib.mkIf config.services.secureboot.enable {
    environment.systemPackages = [
      pkgs.sbctl # for troubleshooting SecureBoot
    ];

    boot = {
      loader = {
        systemd-boot.enable = lib.mkForce false;
        efi.canTouchEfiVariables = true;
      };

      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
