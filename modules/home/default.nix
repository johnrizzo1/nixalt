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
      home-manager
      packages
      alacritty
      # builder-ssh
      catppuccin
      shell
      xdg
      ;
  }; 

  # xdg.configFile."nixpkgs/config.nix".source = ../../nixpkgs-config.nix;
}
