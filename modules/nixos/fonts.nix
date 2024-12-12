{ pkgs, ... }:
{
  fonts = {
    fontDir.enable = true;

    packages = with pkgs; [
      nerd-fonts.fira-code
      fira-code-symbols
      jetbrains-mono
      noto-fonts
    ];
  };
}
