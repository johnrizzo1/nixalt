{ inputs, pkgs, ... }:
{
  users.users.jrizzo = {
    home = "/Users/jrizzo";
    shell = pkgs.zsh;
  };

  # fonts = {
  #   packages = with pkgs; [
  #     cascadia-code
  #     (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
  #   ];
  # };

  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    primaryUser = "jrizzo";
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
          "/Applications/VSCodium.app"
          "/Applications/Obsidian.app"
        ];
        persistent-others = [
          "/Users/jrizzo/Downloads"
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
