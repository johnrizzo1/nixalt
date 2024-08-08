{
  pkgs,
  user_config,
  host_config,
  ...
}: {
  imports = [];

  users.users.jrizzo.home =
    (
      if pkgs.stdenv.isDarwin
      then "/Users/"
      else "/home/"
    )
    + "jrizzo";
  # user_config.users.jrizzo // { shell = pkgs.zsh; } // { home = (if pkgs.lib.stdenv.isDarwin then "/Users/" else "/home/") + "jrizzo"; };
  users.users.root.home =
    if pkgs.stdenv.isDarwin
    then "/var/root"
    else "/root";
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
