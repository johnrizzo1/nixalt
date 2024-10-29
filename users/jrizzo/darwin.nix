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
