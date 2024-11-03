{ pkgs
, lib
, ...
}:
{
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
  services = {
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
    desktopManager = {
      plasma6 = {
        enable = true;
        enableQt5Integration = true;
      };
    };
  };
}
