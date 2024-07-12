{ user_config, pkgs, ... }: let
  inherit (pkgs.stdenv) isDarwin;
in {

  # import sub modules
  imports = [
    # ./nixpkgs.nix
    ./core.nix
    ./shell.nix
    # ./programs/neovim.nix
    # ./programs/eza.nix
    ./programs/git.nix
    # ./programs/starship.nix
    # ./programs/vscode.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    homeDirectory = (if isDarwin then "/Users/" else "/home/") + user_config.username;

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
