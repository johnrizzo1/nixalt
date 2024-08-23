{
  pkgs,
  lib,
  ezModules,
  ...
}: {
  users.users.jrizzo.home = 
    if pkgs.stdenv.isDarwin
    then "/Users/jrizzo"
    else "/home/jrizzo";

  users.users.root.home =
    if pkgs.stdenv.isDarwin
    then "/var/root"
    else "/root";
  
  nixpkgs.hostPlatform = "aarch64-darwin";
}
