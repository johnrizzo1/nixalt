{ pkgs, config, lib, ... }: {
  services = {
    # activate-system.enable = true;
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
          "/Applications/Visual Studio Code.app"
          "/Applications/Obsidian.app"
        ];
        persistent-others = [
          "~/Downloads"
          "/Applications"
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

    # Set Git commit hash for darwin-version.
    # configurationRevision = self.rev or self.dirtyRev or null;
    stateVersion = 5;
  };
}
