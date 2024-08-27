{ config, ... }: {
  programs.gpg = {
    enable = false;
    homedir = "${config.xdg.dataHome}/gnupg";
  };
}