{
  ezModules,
  inputs,
  lib,
  ...
}: {
  imports = lib.attrValues {
    inherit
      (ezModules)
      # _1password
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
