{
  pkgs,
  ...
}: {
  networking.hostName = "tymnet";

  users.users.jrizzo.home = 
    if pkgs.stdenv.isDarwin
    then "/Users/jrizzo"
    else "/home/jrizzo";


  #
  # Packages
  environment.systemPackages = with pkgs; [
    hugo
    git-lfs
  ];
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
      "sketch"
      "gimp"
      "krita"
      "figma"
      "blender"
      "inkscape"
      "gns3"
      "balenaetcher"
      "bambu-studio"
      "calibre"
      "discord"
      "jan" # Offline AI Tool like LMStudio
      "nvidia-geforce-now"
      "obs"
      "obsidian"
      "orcaslicer"
      "pycharm-ce"
      "raspberry-pi-imager"
      "raycast"
      "rectangle"
      # "royal-tsx"
      "rustdesk"
      "signal"
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
      "microsoft-office"
      # "microsoft-teams"
      # "onedrive"
      # "prismlauncher"
      # "protonmail-bridge"
      # "protonvpn"
      # "quicken" # Failed to install
      # "reader" #failed
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
