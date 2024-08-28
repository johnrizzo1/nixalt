# Use this to configure your home environment
# (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  ezModules,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  # imports = if isDarwin then lib.attrValues {
  #     inherit (ezModules)
  #       darwin;
  #   } else [];

  home = rec {
    username = "jrizzo";
    homeDirectory = (
        if isDarwin
        then "/Users/"
        else "/home/"
      ) + username;
    # stateVersion = "24.05";
  };

  programs.git = {
    userName = "John Rizzo";
    userEmail = "johnrizzo1@gmail.com";
  };

  stateVersion = "24.05";
}
