{ pkgs, ... }:
{
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      fira-code
      fira-code-symbols
      jetbrains-mono
      noto-fonts
    ];
  };
}
