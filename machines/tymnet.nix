{ inputs
, config
, pkgs
, lib
  # , currentSystem
, currentSystemUser
, currentSystemName
, ...
}:
{
  networking = {
    hostName = currentSystemName;
    computerName = currentSystemName;
    localHostName = currentSystemName;
  };

  programs = {
    # zsh is the default shell on Mac and we want to make sure that we're
    # configuring the rc correctly with nix-darwin paths.
    zsh = {
      enable = true;
      shellInit = ''
        # Nix
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        # End Nix
      '';
    };

    bash = {
      enable = true;
      interactiveShellInit = ''
        # Nix
        if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
          source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        end
        # End Nix
      '';
    };

    fish = {
      enable = true;
      shellInit = ''
        # Nix
        if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
          source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        end
        # End Nix
      '';
    };
  };

  environment = {
    shells = with pkgs; [
      bashInteractive
      zsh
      fish
    ];

    #
    # Packages
    systemPackages = with pkgs; [
      unstable.direnv
      unstable.devenv
    ];
  };

  # nixpkgs.config.android_sdk.accept_license = true;

  homebrew = {
    enable = true;

    taps = [
      "hashicorp/tap"
    ];

    brews = [
      "hashicorp/tap/packer"
      "mas"
      "incus"
    ];

    masApps = {
      "1Password for Safari" = 1569813296;
      "Actions for Obsidian" = 1659667937;
      "Apple Configurator" = 1037126344;
      "DS Manager" = 1435876433;
      "Microsoft Remote Desktop" = 1295203466;
      "Remote Desktop" = 409907375;
      "Save to Reader" = 1640236961;
      Canva = 897446215;
      GarageBand = 682658836;
      Kindle = 302584613;
      OmniGraffle = 1142578753;
      TestFlight = 899247664;
      Xcode = 497799835;
    };

    casks = [
      "1password-cli"
      "1password"
      "android-studio"
      "balenaetcher"
      "bambu-studio"
      "blender"
      "calibre"
      "cleanshot"
      "dbeaver-community"
      "discord"
      "docker"
      "element"
      "figma"
      "freetube"
      "gimp"
      "gns3"
      "google-chrome"
      "google-drive"
      "hammerspoon"
      "imageoptim"
      "inkscape"
      "istat-menus"
      "iterm2"
      "jan" # Offline AI Tool like LMStudio
      "krita"
      "microsoft-office"
      "monodraw"
      "nvidia-geforce-now"
      "obs"
      "obsidian"
      "orcaslicer"
      "parallels-virtualization-sdk"
      "parallels"
      "pycharm-ce"
      "raspberry-pi-imager"
      "raycast"
      "rectangle"
      "rustdesk"
      "screenflow"
      "signal"
      "sketch"
      "slack"
      "sonos"
      "sourcetree"
      "spotify"
      "synology-drive"
      "tailscale"
      "transmission"
      "vagrant"
      "visual-studio-code"
      "yubico-yubikey-manager"
      "zoom"
    ];
    onActivation.cleanup = "zap";
  };

  services = {
    tailscale.enable = true;
    # synergy.client = {
    #   enable = true;
    #   autoStart = true;
    #   serverAddress = "coda.technobable.com:24800";
    #   # tls.enable = true;
    # };
  };

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 5;
}
