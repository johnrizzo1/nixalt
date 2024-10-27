{ pkgs, ... }: {
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      fira-code
      fira-code-nerdfont
      fira-code-symbols
      jetbrains-mono
      nerdfonts
      noto-fonts
    ];
  };
}
