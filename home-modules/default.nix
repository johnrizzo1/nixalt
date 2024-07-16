{
  user_config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
  user = "jrizzo"; #TODO Fix this to be generic
in {
  imports = [
    ./common/core.nix
    ./common/shell.nix
    ./common/desktop.nix #TODO: make this only take effect if needed
  ];

  home = {
    homeDirectory =
      (
        if isDarwin
        then "/Users/"
        else "/home/"
      )
      + user_config.users."${user}_info".username;

    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";
}
