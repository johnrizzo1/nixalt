{ inputs, pkgs, ... }:

{
  # nixpkgs.overlays = import ../../lib/overlays.nix;
  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
  security.pam.enableSudoTouchIdAuth = true;

  homebrew = {
    enable = true;
    casks  = [
      "1password"
      "blender"
      "cleanshot"
      "discord"
      "figma"
      "gimp"
      "gns3"
      "google-chrome"
      "hammerspoon"
      "imageoptim"
      "inkscape"
      "istat-menus"
      "krita"
      "monodraw"
      "raycast"
      "rectangle"
      "screenflow"
      "sketch"
      "slack"
      "spotify"
    ];
  };

  users.users.jrizzo = {
    home = "/Users/jrizzo";
    shell = pkgs.fish;
  };
  
  services.nix-daemon.enable = true;
  # nix.useDaemon = true;
}