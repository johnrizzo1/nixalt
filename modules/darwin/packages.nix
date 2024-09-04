{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # chromium
    direnv
    devenv
    home-manager
  ];

  homebrew = {
    enable = true;
    brews = [];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Save to Reader" = 1640236961;
      "Remote Desktop" = 409907375;
      Telegram = 747648890;
      OmniGraffle = 1142578753;
      GarageBand = 682658836;
      "DS Manager" = 1435876433;
      "Actions for Obsidian" = 1659667937;
      Canva = 897446215;
      "Apple Configurator" = 1037126344;
      "Microsoft Remote Desktop" = 1295203466;
      TestFlight = 899247664;
      Kindle = 302584613;
      Xcode = 497799835;
    };
    casks = [
      "1password"
      "balenaetcher"
      "bambu-studio"
      "calibre"
      "discord"
      "google-chrome"
      "iterm2"
      "nvidia-geforce-now"
      "obs"
      "obsidian"
      "orcaslicer"
      "parallels"
      "pycharm-ce"
      "raspberry-pi-imager"
      "raycast"
      "rectangle"
      "royal-tsx"
      "rustdesk"
      "signal"
      "slack"
      "sonos"
      "sourcetree"
      "synology-drive"
      "tailscale"
      "transmission"
      "yubico-yubikey-manager"
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
    onActivation.cleanup = "zap";
  };
}
