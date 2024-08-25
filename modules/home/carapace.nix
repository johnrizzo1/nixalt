{ pkgs, lib, ... }: {
  programs = {
    carapace = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };
}