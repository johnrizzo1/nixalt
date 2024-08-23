{ ... }: {
  programs.kitty = {
    enable = true;

    font = {
      size = 13;
      name = "CaskaydiaCove Nerd Font";
    };

    extraConfig = ''
      bold_font CaskaydiaCove NF Bold
      italic_font CaskaydiaCove NF Italic
      bold_italic_font CaskaydiaCove NF Bold Italic
    '';
  };
}