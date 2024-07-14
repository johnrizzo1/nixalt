{
  user_config,
  user,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  imports = [
    ./core.nix
    ./shell.nix
    ./programs/git.nix
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
