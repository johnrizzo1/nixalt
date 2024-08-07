{inputs, pkgs, ...}: let
  inherit (pkgs.stdenv) isLinux;
in {
  xdg.mimeApps = if isLinux then {
    enable = true;
    defaultApplications = {
      "application/obsidian" = 
        ["md.obsidian.Obsidian.desktop"];
    };
  } else {};
}
