{ pkgs, ... }:
{
  programs.obs-studio.enable = pkgs.stdenv.isLinux;
  programs.obs-studio.plugins = with pkgs.obs-studio-plugins; [
    input-overlay
    obs-backgroundremoval
    obs-composite-blur
    obs-freeze-filter
    obs-mute-filter
    obs-vkcapture
    wlrobs
  ];
}
