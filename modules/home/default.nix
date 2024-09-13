{
  ezModules,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = lib.attrValues {
    inherit
      (ezModules)
      # alacritty
      # builder-ssh

      # catppuccin
      editor
      home-manager
      packages
      shell
      xdg
      obs
      ;
  };

  home.stateVersion = "24.05";
}
