{
  ezModules,
  lib,
  ...
}: {
  imports = lib.attrValues {
    inherit
      (ezModules)
      alacritty
      
      builder-ssh
      catppuccin
      neovim
      # nushell
      
      shell-generic
      shell-utils
      tmux
      xdg
      yazi
      zsh
      ;
  };

  home = {
    stateVersion = "24.05";
  };

  xdg.configFile."nixpkgs/config.nix".source = ../nixpkgs-config.nix;
  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
}
