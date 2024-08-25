{ pkgs, inputs, lib, ... }: {
  # imports = [
  #   inputs.lanzaboote.nixosModules.lanzaboote
  # ];

  environment.systemPackages = [
    pkgs.sbctl # for troubleshooting SecureBoot
  ];

  # boot.loader.systemd-boot.enable = lib.mkForce false;

  # boot.lanzaboote = {
  #   enable = true;
  #   pkiBundle = "/etc/secureboot";
  # };
}