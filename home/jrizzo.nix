# Use this to configure your home environment
# (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  user_config,
  ...
}: let
  _username = user_config.users.jrizzo_info.username;
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    inputs.nix-colors.homeManagerModules.default
    inputs.catppuccin.homeManagerModules.catppuccin

    # You can also split up your configuration and import pieces of it here:
    ./common
  ];

  # The color scheme for nix-colors
  colorScheme = inputs.nix-colors.colorSchemes.paraiso;

  nixpkgs.config.allowUnfree = true;

  home = {
    username = _username;

    # Add stuff for your user as you see fit:
    # packages = with pkgs; [ ];
  };
}
