{pkgs, ...}: let
  inherit (pkgs.stdenv) isLinux;
in {
  home.shellAliases.ssh = "TERM=xterm-256color; ssh";

  programs = {
    alacritty = {
      enable = true;

      settings = {
        window.dimensions = {
          columns = 130;
          lines = 36;
        };

        font = {
          italic.style = "Italic";
          bold.style = "Bold";
          bold_italic.style = "Bold Italic";
          size =
            if isLinux
            then 13
            else 15;

          normal = {
            family = "CaskaydiaCove Nerd Font";
            style = "Regular";
          };
        };
      };
    };
  };
}
