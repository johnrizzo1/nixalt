# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  networking.hostName = "nixalot"; # Define your hostname.
  
  # Enable automatic login for the user.
  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "jrizzo";
  services.tailscale.enable = true;
}