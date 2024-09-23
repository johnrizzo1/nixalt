{ ezModules, pkgs, inputs, lib, config, ... }: {
  imports = lib.attrValues {
    inherit (ezModules)
      networking
      nix
      nixpkgs
      packages
      ssh
      users
      ;
  };

  # default host level packages and shell setup
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment = {
    pathsToLink = ["/share/zsh"];
    systemPackages = with pkgs; [
      zsh
      coreutils
      vim
      wget
      git
      home-manager
      direnv
      devenv
      tmux
    ];
    variables = {
      EDITOR = "vi";
    };
  };
  
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  system.stateVersion = "24.05";
}
