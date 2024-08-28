{
  pkgs,
  lib,
  ezModules,
  ...
}: {
  networking.hostName = "macosdev";

  users.users.jrizzo.home = 
    if pkgs.stdenv.isDarwin
    then "/Users/jrizzo"
    else "/home/jrizzo";

  users.users.root.home =
    if pkgs.stdenv.isDarwin
    then "/var/root"
    else "/root";
  
  nixpkgs.hostPlatform = lib.mkForce "aarch64-darwin";
}
