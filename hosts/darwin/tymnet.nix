{
  pkgs,
  lib,
  ezModules,
  ...
}: {
  imports = lib.attrValues {
    inherit (ezModules)
      darwin;
  };

  users.users.jrizzo.home = 
    if pkgs.stdenv.isDarwin
    then "/Users/jrizzo"
    else "/home/jrizzo";

  users.users.root.home =
    if pkgs.stdenv.isDarwin
    then "/var/root"
    else "/root";
  
  # nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
