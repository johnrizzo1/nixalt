# Use this to configure your home environment
# (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: {
  home = rec {
    username = "jrizzo";
    homeDirectory =
      if pkgs.stdenv.isDarwin
      then "/Users/jrizzo"
      else "/home/jrizzo";
  };

  programs.git = {
    userName = "John Rizzo";
    userEmail = "johnrizzo1@gmail.com";
  };
}
