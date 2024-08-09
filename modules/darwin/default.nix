{
  ezModules,
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = lib.attrValues {
    inherit (ezModules)
      nixpkgs
      nix;
  };

  programs.zsh.enable = true;
  security.pam.enableSudoTouchIdAuth = true;

  homebrew = {
    enable = true;
    
    taps = [
      "homebrew/homebrew-core"
      "homebrew/homebrew-cask"
    ];

    # brews = [];
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

  # fonts = {
  #   packages = with pkgs; [
  #     cascadia-code
  #     (nerdfonts.override {fonts = ["CascadiaCode"];})
  #   ];
  # };

  environment = {
    pathsToLink = ["/share/zsh"];
    systemPackages = with pkgs; [
      zsh
      coreutils
      home-manager
      mas
      direnv
      devenv
      hello
    ];
    variables = {
      EDITOR = "vi";
    };
  };

  # nix = {
  #   extraOptions = "experimental-features = nix-command flakes";

  #   settings = {
  #     trusted-users = ["@admin"];
  #     trusted-substituters = ["https://nix-community.cachix.org"];
  #     extra-substituters = ["https://nix-community.cachix.org"];
  #     extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
  #   };

  #   gc = {
  #     automatic = true;
  #     options = "--delete-older-than 7d";
  #     interval = {
  #       Hour = 3;
  #       Minute = 15;
  #       Weekday = 6;
  #     };
  #   };

  #   registry = {
  #     nixpkgs.flake = inputs.nixpkgs-darwin;
  #   };

  #   nixPath = [
  #     "nixpkgs=${inputs.nixpkgs-darwin}"
  #   ];
  # };

  services.nix-daemon.enable = true;
}
