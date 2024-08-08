# Use this to configure your home environment
# (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  ezModules,
  config,
  pkgs,
  user_config,
  ...
}: let
  inherit (pkgs.stdenv) isDarwin;
in {
  imports = lib.attrValues {
    inherit
      (ezModules)
      darwin
      ;
  };

  home = rec {
    username = "jrizzo";
    homeDirectory =
      (
        if isDarwin
        then "/Users/"
        else "/home/"
      )
      + username;
    stateVersion = "24.05";
  };

  programs.git = {
    userName = "John Rizzo";
    userEmail = "johnrizzo1@gmail.com";
    extraConfig.commit.gpgsign = false;
  };

  # programs.ssh = {
  #   enable = true;
  #   extraConfig = ''
  #     Host *
  #       IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
  #   '';
  # };
}
