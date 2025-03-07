{ inputs
, config
, pkgs
, lib
, currentSystemUser
, currentSystemName
, ...
}:
{
  imports = [
    ./common/darwin.nix
  ];

  networking = {
    hostName = currentSystemName;
    computerName = currentSystemName;
    localHostName = currentSystemName;
  };

  homebrew = {
    enable = true;
    # taps = {
    #   "andrewinci/tap"
    # };
    brews = [
      "incus"
      "mas"
      # "texlive"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "Actions for Obsidian" = 1659667937;
      "Apple Configurator" = 1037126344;
      "DS Manager" = 1435876433;
      "Microsoft Remote Desktop" = 1295203466;
      "Readwise" = 1476885528;
      "Save to Reader" = 1640236961;
      Canva = 897446215;
      GarageBand = 682658836;
      Kindle = 302584613;
      TestFlight = 899247664;
      Xcode = 497799835;
    };
    casks = [
      "1password-cli"
      "1password"
      "android-studio"
      "balenaetcher"
      "bambu-studio"
      "beeper"
      "calibre"
      "claude"
      "cyberduck"
      "diffusionbee"
      "discord"
      "draw-things"
      "freetube"
      "gimp"
      "gns3"
      "google-chrome"
      "imageoptim"
      "inkscape"
      "istat-menus"
      "iterm2"
      "jan"
      "jetbrains-toolbox"
      "kdenlive"
      "microsoft-office"
      "microsoft-teams"
      "nvidia-geforce-now"
      "obs"
      "obsidian"
      "ollama"
      "orcaslicer"
      "parallels"
      "podman-desktop"
      "raspberry-pi-imager"
      "slack"
      "signal"
      "sonos"
      "sourcetree"
      "synology-drive"
      "tailscale"
      "visual-studio-code"
      "yubico-yubikey-manager"
    ];
    onActivation.cleanup = "zap";
  };

  environment = {
    shells = with pkgs; [
      bashInteractive
      zsh
      fish
    ];

    systemPackages = with pkgs; [
      podman
      kind
      kubectl
      kubernetes-helm
      docker-compose
      opentofu
      terragrunt
      virt-manager
      dotnet-sdk
      dbeaver-bin
      postgresql
      element-desktop
      (python3.withPackages (ps: with ps; [ 
        latexminted
        latexrestricted
        latex2pydata
        pygments
      ]))
      # needed to add this to darwin-rebuild.. --option extra-sandbox-paths /nix/store
      # https://github.com/NixOS/nix/issues/4119
      texlive.combined.scheme-full
    ];
  };

  programs = {
    # zsh is the default shell on Mac and we want to make sure that we're
    # configuring the rc correctly with nix-darwin paths.
    zsh = {
      enable = true;
      shellInit = ''
        # Nix
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        # End Nix
      '';
    };

    bash = {
      enable = true;
      interactiveShellInit = ''
        # Nix
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        # End Nix
      '';
    };

    fish = {
      enable = true;
      shellInit = ''
        # Nix
        if test -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
          source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish'
        end
        # End Nix
      '';
    };
  };

  services = {
    tailscale.enable = true;
    nix-daemon.enable = true;
  };
}
