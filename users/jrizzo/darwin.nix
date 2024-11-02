{ inputs
, pkgs
, ...
}: {
  # nixpkgs.overlays = import ../../lib/overlays.nix;
  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];

  security.pam.enableSudoTouchIdAuth = true;
  services.activate-system.enable = true;

  nix = {
    # enable = true;
    settings = {
      # keep-derivations = true;
      # keep-outputs = true;
      allowed-users = [ "*" ];
      auto-optimise-store = false;
      cores = 0;
      experimental-features = [ "nix-command" "flakes" ];
      extra-sandbox-paths = [ ];
      max-jobs = "auto";
      require-sigs = true;
      sandbox = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
      ];
      system-features = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
      trusted-substituters = [ ];
      trusted-users = [ "root" "jrizzo" ];
    };
  };

  homebrew = {
    enable = true;
    brews = [
      "mas"
    ];
    casks = [
      "1password"
      "blender"
      "cleanshot"
      "discord"
      "figma"
      "freetube"
      "gimp"
      "gns3"
      "google-chrome"
      "hammerspoon"
      "imageoptim"
      "inkscape"
      "istat-menus"
      "iterm2"
      "krita"
      "monodraw"
      "raycast"
      "rectangle"
      "screenflow"
      "sketch"
      "slack"
      "spotify"
    ];
  };

  # environment.systemPackages = [ ];

  # home.packages = with pkgs; [ ];

  users.users.jrizzo = {
    home = "/Users/jrizzo";
    shell = pkgs.zsh;
  };

  services.nix-daemon.enable = true;
  # nix.useDaemon = true;

  # Find more options here
  # https://daiderd.com/nix-darwin/manual/index.html

  system.defaults = {
    NSGlobalDomain = {
      _HIHideMenuBar = true;
      AppleKeyboardUIMode = 3;
      ApplePressAndHoldEnabled = false;
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      InitialKeyRepeat = 0;
      KeyRepeat = 10;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
    };

    dock = {
      autohide = false;
      mru-spaces = false;
      orientation = "bottom";
      showhidden = true;
      persistent-apps = [
        "/Applications/VSCodium.app"
        "/Applications/Obsidian.app"
      ];
      persistent-others = [
        "~/Downloads"
      ];
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      QuitMenuItem = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = true;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
