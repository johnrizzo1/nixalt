{pkgs, ...}: {
  imports = [
    ./programs/vscodium.nix # or vscode.nix
    ./programs/obsidian.nix
  ];

  home.packages = with pkgs; [
    steam
    obsidian
    cider # Apple Music on Linux
    discord
    firefox
    _1password-gui

    # KDE Packages
    kdePackages.kmail
    kdePackages.kdepim-addons

    #
    # For vscode and the extensions to work
    vscodium.fhs # or vscode

    audacity
    bambu-studio
    catppuccin-gtk
    desktop-file-utils
    obsidian
    signal-desktop
    todoist-electron
    xorg.xlsclients
    xdg-utils
    pamixer
    pavucontrol
  ];
}
