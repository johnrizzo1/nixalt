{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # chromium
    direnv
    devenv
    home-manager
  ];

  homebrew = {
    enable = true;
    brews = [ ];
    masApps = {
      "Apple Configurator" = 1037126344;
      "Microsoft Remote Desktop" = 1295203466;
    };
    casks = [
      "google-chrome"
      "iterm2"
      "parallels"
      "tailscale"
      "yubico-yubikey-manager"
    ];
    onActivation.cleanup = "zap";
  };
}
