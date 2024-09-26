{ inputs, pkgs, ... }:

{
  nixpkgs.overlays = import ../../lib/overlays.nix;
  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];

  homebrew = {
    enable = true;
    casks  = [
      "1password"
      "cleanshot"
      "discord"
      "google-chrome"
      "hammerspoon"
      "imageoptim"
      "istat-menus"
      "monodraw"
      "raycast"
      "rectangle"
      "screenflow"
      "slack"
      "spotify"
    ];
  };

  users.users.jrizzo = {
    home = "/Users/jrizzo";
    shell = pkgs.fish;
    group = "jrizzo";
    isNormalUser = true;
  };
}