{ lib, ... }:
{
  networking = {
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networkmanager.enable = true;

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    useDHCP = lib.mkDefault true;
    # interfaces.enp3s0.useDHCP = lib.mkDefault true;
    # interfaces.wlo1.useDHCP = lib.mkDefault true;

    firewall = {
      # Open ports in the firewall.
      allowedTCPPorts = [ 22 ];
      # allowedUDPPorts = [ ... ];
      # Or disable the firewall altogether.
      enable = true;
    };
  };
}
