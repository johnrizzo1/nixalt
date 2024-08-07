{pkgs, ...}: {
  imports = [
    ./programs/starship.nix
    ./programs/eza.nix
    ./programs/zsh.nix
    ./programs/tmux.nix
  ];

  home.packages = with pkgs; [
    tmux
    tmate
    tmux-mem-cpu-load
    tmuxPlugins.battery
    tmuxPlugins.catppuccin
    tmuxPlugins.cpu
    tmuxPlugins.weather
  ];
}
