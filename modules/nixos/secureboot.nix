{ config
, pkgs
, inputs
, lib
, ...
}:
{
  # imports = [
  #   inputs.lanzaboote.nixosModules.lanzaboote
  # ];

  options.services.secureboot = {
    # enable = lib.mkEnableOption "secure boot";
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "enable secure boot?";
    };
  };

  # https://nixos.wiki/wiki/Secure_Boot
  # Setup
  # * bootctl status should be using systemd, firmware=uefi, tpm2 support=yes
  # * sudo sbctl create-keys
  # * sudo sbctl verify
  # * sudo sbctl everything not windows, not bzimage.efi
  # * reboot
  # * sudo sbctl enroll-keys --microsoft
  # * reboot to enable UEFI+SecureBoot

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
