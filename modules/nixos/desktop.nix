{ pkgs
, lib
, config
, ...
}:
{
  imports = [
    ./fonts.nix
    # ./kde.nix
  ];

  options.services.desktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Enable my custom desktop config";
    };
    desktopManager = lib.mkOption {
      description = "The desktop manager you would like to use kde, gnome, etc.";
      type = lib.types.string;
      default = "kde";
    };
  };

  config = lib.mkIf config.services.desktop.enable {
    # Enable the GNOME Desktop Environment.
    # services.xserver.displayManager.gdm.enable = true;
    # services.xserver.desktopManager.gnome.enable = true;
    # services.gnome.gnome-remote-desktop.enable = true;
    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };

    # Make QT apps look like dark themed Gnome apps
    # qt = {
    #   enable = true;
    #   platformTheme = "gnome";
    #   style = "adwaita-dark";
    # };

    # Enable the XFCE Desktop Environment.
    # services.xserver.displayManager.lightdm.enable = true;
    # services.xserver.desktopManager.xfce.enable = true;

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

    services = {
      displayManager.sddm.enable = true;
      # Enable the KDE Desktop Environment
      displayManager.sddm.wayland.enable = true;
      desktopManager.plasma6.enable = true;
      desktopManager.plasma6.enableQt5Integration = true;

      # Enable the deepin desktop environment
      # displayManager.lightdm.enable = true;
      # desktopManager.deepin.enable = true;

      xserver = {
        # Enable the X11 windowing system.
        enable = true;

        # Configure keymap in X11
        xkb.layout = "us";
        xkb.variant = "";
      };

      # Enable CUPS to print documents.
      printing.enable = true;
      pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        # If you want to use JACK applications, uncomment this
        #jack.enable = true;

        # use the example session manager (no others are packaged yet so this is enabled by default,
        # no need to redefine it in your config for now)
        #media-session.enable = true;
      };

      # Enable touchpad support (enabled default in most desktopManager).
      libinput.enable = true;
    };

    # Enable sound with pipewire.
    hardware.pulseaudio.enable = false;
    # services.pulseaudio.enable = false;
  
    security.rtkit.enable = true;
  };
}
