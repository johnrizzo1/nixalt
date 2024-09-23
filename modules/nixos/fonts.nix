{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    noto-fonts
    fira-code
    fira-code-symbols
    nerdfonts
  ];
}