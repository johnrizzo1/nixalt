{ inputs, pkgs, ... }:
{
  # environment.systemPackages = [ ];
  # home.packages = with pkgs; [ ];

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

  users.users.jrizzo = {
    home = "/Users/jrizzo";
    shell = pkgs.zsh;
  };

  services = {
    activate-system.enable = true;
    nix-daemon.enable = true;
  };

  security.pam.enableSudoTouchIdAuth = true;

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    # Find more options here
    # https://daiderd.com/nix-darwin/manual/index.html
    defaults = {
      NSGlobalDomain = {
        _HIHideMenuBar = false;
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        InitialKeyRepeat = 0;
        KeyRepeat = 0;
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
  };
}
