{
  pkgs,
  inputs,
  ...
}: {
  programs.zsh.enable = true;
  security.pam.enableSudoTouchIdAuth = true;
  nixpkgs.config = import ../nixpkgs-config.nix;

  homebrew = {
    enable = true;
    # brews = [];
    masApps = {
      "1Password for Safari" = 1569813296;
      Xcode = 497799835;
    };
    taps = [
      "homebrew/cask"
    ];
    casks = [
      "1password"
      # balena etcher
      # bambu studio
      # "aldente"
      # "anydesk"
      # "arc"
      "calibre"
      # canva
      # "chatterino"
      # creality scan
      "discord"
      "docker"
      # ds manager
      # ea app
      # ez receipts
      # gardyn
      # Google Docs/Sheets/Drive/Slides
      # GroupSpot
      # Hopper Dissassembler
      "iterm2"
      # Kindle
      # "keycastr"
      # "linearmouse"
      # lm studio
      # "logitech-g-hub"
      # "maccy"
      "microsoft-office"
      "microsoft-teams"
      # mutebar
      "nvidia-geforce-now"
      # OBS
      "obsidian"
      # OmniGraffle
      # OneDrive
      # OrcaSlicer
      "parallels"
      # "prismlauncher"
      # "protonmail-bridge"
      # "protonvpn"
      "quicken"
      # Raspberry Pi Imager
      "raycast"
      "reader"
      "rectangle"
      # Rhino8
      "royal-tsx"
      "rustdesk"
      # "rwts-pdfwriter"
      # Save to Reader
      "signal"
      "slack"
      "sonos"
      "sourcetree"
      # "soundsource"
      # "spotify"
      # "steam"
      # Synology Drive Client
      "tailscale"
      # Telegram
      # "teamviewer"
      "transmission"
      # Visual Studio Code
      # Visual Studio
      # "whatsapp"
      # xcode
      # "via"
      # "vlc"
      # "xiv-on-mac"
      # "yacreader"
      "yubico-yubikey-manager"
      "zoom"
    ];
    onActivation.cleanup = "zap";
  };

  fonts = {
    packages = with pkgs; [
      cascadia-code
      (nerdfonts.override {fonts = ["CascadiaCode"];})
    ];
  };

  environment = {
    pathsToLink = ["/share/zsh"];
    systemPackages = with pkgs; [
      zsh
      coreutils
      home-manager
      mas
      hello
    ];
    variables = {
      EDITOR = "nvim";
    };
  };

  nix = {
    extraOptions = "experimental-features = nix-command flakes";

    settings = {
      trusted-users = ["@admin"];
      trusted-substituters = ["https://nix-community.cachix.org"];
      extra-substituters = ["https://nix-community.cachix.org"];
      extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      interval = {
        Hour = 3;
        Minute = 15;
        Weekday = 6;
      };
    };

    registry = {
      nixpkgs.flake = inputs.nixpkgs-darwin;
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs-darwin}"
    ];
  };

  services.nix-daemon.enable = true;
}
