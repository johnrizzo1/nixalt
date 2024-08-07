# Use this to configure your home environment
# (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  user_config,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  home = rec {
    username = "jrizzo";
    homeDirectory = 
      if isDarwin
      then "/Users/"
      else "/home/" + username;
  };

  programs.git = {
    userName = "John Rizzo";
    userEmail = "johnrizzo1@gmail.com";
  };
}
