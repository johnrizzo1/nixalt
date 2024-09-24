{
  pkgs,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    kdePackages.konsole
    kdePackages.plasma-browser-integration
    # (lib.getBin qttools)
    ark
    elisa
    gwenview
    okular
    kate
    khelpcenter
    dolphin
    kdePackages.dolphin-plugins
    spectacle
    ffmpegthumbs
    # krdp
    kdePackages.yakuake
    # kdePackages.kwallet
    # kdePackages.kwallet-pam
    merkuro
  ];


  # Enable the KDE Desktop Environment
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.plasma6.enableQt5Integration = true;
}