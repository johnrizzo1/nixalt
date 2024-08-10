{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # chromium
  ];

  homebrew = {
    enable = true;
    
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
    ];

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
      "google-chrome"
      "discord"
      "docker"
      "iterm2"
      "microsoft-office"
      "microsoft-teams"
      "nvidia-geforce-now"
      "obs-advanced-scene-switcher"
      "obs-ndi"
      "obs-virtualcam"
      "obs"
      "obsidian"
      # "onedrive"
      "orcaslicer"
      "parallels"
      "quicken"
      "raspberry-pi-imager"
      "raycast"
      "reader"
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
      # "whatsapp"
      "yubico-yubikey-manager"
      "zoom"
      # "aldente"
      # "anydesk"
      # "arc"
      # "chatterino"
      # "keycastr"
      # "linearmouse"
      # "logitech-g-hub"
      # "maccy"
      # "prismlauncher"
      # "protonmail-bridge"
      # "protonvpn"
      # "rwts-pdfwriter"
      # "soundsource"
      # "spotify"
      # "steam"
      # "teamviewer"
      # "via"
      # "vlc"
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