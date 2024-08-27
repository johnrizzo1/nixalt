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
  # ++ lib.optional pkgs.stdenv.isDarwin (lib.attrValues {
  #  inherit (pkgs)
  #    orc
  #    ;
  #});

  home.packages = lib.attrValues {
    inherit (pkgs)
      orca-slicer
      hugo
      zoom
      ;
  };
  
  # environment.systemPackages = with pkgs; 
  #   if pkgs.stdenv.isLinux then [
  #     orca-slicer
  #   ] else [];
}