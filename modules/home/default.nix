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
      alacritty
      # builder-ssh
      catppuccin
      editor
      home-manager
      packages
      shell
      xdg
      desktop
      ;
  }; 

  home-manager.users."jrizzo" = {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = [ "qemu:///system" ];
        uris = [ "qemu:///system" ];
      };
    };
  };
}
