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
  };
}