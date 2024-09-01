{
  ezModules,
  inputs,
  lib,
  pkgs,
  ...
}: {
  ###
  ### TODO
  ### Convert this to optional modules. so that it is only applied when linux
  # imports =  [] ++ lib.optional pkgs.stdenv.isLinux
    # lib.attrValues { # linux
      # inherit (ezModules)
        # obs
  #       kde 
  #       # Todo move gnome options here and create option to select
        # ;
    # };
  #   } else lib.attrValues { }; # darwin

  # home.packages = 
  #   if pkgs.stdenv.isLinux 
  #   then lib.attrValues {
  #     inherit (pkgs)
  #       orca-slicer
  #       hugo
  #       zoom
  #       firefox
  #       ;
  #   } else lib.attrValues { };
  
  # environment.systemPackages =
  #   if pkgs.stdenv.isLinux
  #   then [ pkgs.orca-slicer ]
  #   else [];
}