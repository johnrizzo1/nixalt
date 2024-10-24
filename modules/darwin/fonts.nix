{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      cascadia-code
      (nerdfonts.override {fonts = ["CascadiaCode"];})
    ];
  };
}
