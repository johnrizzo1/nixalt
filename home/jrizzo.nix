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
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    ./common
    # ./common/programs/vscode.nix
    ./common/programs/vscodium.nix
    ./common/programs/obsidian.nix
  ];

  # The color scheme for nix-colors
  colorScheme = inputs.nix-colors.colorSchemes.paraiso;

  nixpkgs.config.allowUnfree = true;

  # config.useremail = "johnrizzo1@gmail.com";

  home = {
    username = user_config.username;
    # homeDirectory = user_config.homebase + '/' + user_config.username;

    # Add stuff for your user as you see fit:
    packages = with pkgs; [
      steam
      vscodium.fhs
      # vscode
      obsidian
      # productivity
      glow # markdown previewer in terminal
      firefox
      kdePackages.kmail
      kdePackages.kdepim-addons
    ];
  };
}
