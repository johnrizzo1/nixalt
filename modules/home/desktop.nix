{
  ezModules,
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = lib.attrValues {
    inherit (ezModules)
      obs
      kde; 
      # Todo move gnome options here and create option to select
  };
}