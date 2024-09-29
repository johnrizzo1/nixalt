{
  pkgs,
  ...
}: {
  imports = [ ../modules/darwin ];

  networking.hostName = "tymnet";

  # users.users.jrizzo.home = 
  #   if pkgs.stdenv.isDarwin
  #   then "/Users/jrizzo"
  #   else "/home/jrizzo";

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
    '';

  programs.fish.enable = true;
  programs.fish.shellInit = ''
    # Nix
    if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
      source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
    end
    # End Nix
    '';

  environment.shells = with pkgs; [ bashInteractive zsh fish ];


  #
  # Packages
  # environment.systemPackages = with pkgs; [];

  # nixpkgs.config.android_sdk.accept_license = true;

  homebrew = {
    masApps = {
      "Save to Reader" = 1640236961;
      "Remote Desktop" = 409907375;
      OmniGraffle = 1142578753;
      GarageBand = 682658836;
      "DS Manager" = 1435876433;
      "Actions for Obsidian" = 1659667937;
      Canva = 897446215;
      TestFlight = 899247664;
      Kindle = 302584613;
      Xcode = 497799835;
    };

    casks = [
      "android-studio"
      "balenaetcher"
      "bambu-studio"
      "blender"
      "calibre"
      "dbeaver-community"
      "discord"
      "figma"
      "gimp"
      "gns3"
      "inkscape"
      "jan" # Offline AI Tool like LMStudio
      "krita"
      "microsoft-office"
      "nvidia-geforce-now"
      "obs"
      "obsidian"
      "orcaslicer"
      "pycharm-ce"
      "raspberry-pi-imager"
      "raycast"
      "rectangle"
      "rustdesk"
      "signal"
      "sketch"
      "slack"
      "sonos"
      "sourcetree"
      "synology-drive"
      "transmission"
      "vscodium"
      "zoom"
      # "aircrack-ng" # failed
      # "aldente"
      # "anydesk"
      # "arc"
      # "chatterino"
      # "docker" # Failed to install
      # "keycastr"
      # "linearmouse"
      # "logitech-g-hub"
      # "maccy"
      # "microsoft-teams"`
      # "prismlauncher"
      # "protonmail-bridge"
      # "protonvpn"
      # "quicken" # Failed to install
      # "reader" #failed
      # "royal-tsx"
      # "rwts-pdfwriter"
      # "soundsource"
      # "spotify"
      # "steam"
      # "teamviewer"
      # "via"
      # "vlc"
      # "whatsapp"
      # "xiv-on-mac"
      # "yacreader"
      # creality scan
      # ds manager
      # ea app
      # ez receipts
      # gardyn
      # Google Docs/Sheets/Drive/Slides
      # GroupSpot
      # Hopper Dissassembler
      # lm studio
      # mutebar
      # Rhino8
      # Visual Studio
      # Visual Studio Code
    ];
  };

  #
  # Other Options
  nix.settings.experimental-features = "nix-command flakes";
  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;
}
