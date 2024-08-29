{ config, pkgs, inputs, lib, ... }: {
  environment.systemPackages = [
    pkgs.sbctl # for troubleshooting SecureBoot
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  options = {
    enable = mkEnbaleOption "secure boot";
  };

  config = lib.mkIf config.services.secureboot.enable {
    # imports = [
    #   inputs.lanzaboote.nixosModules.lanzaboote
    # ];

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}