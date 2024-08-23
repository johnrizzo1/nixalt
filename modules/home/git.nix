{ pkgs, lib, ... }: {
  home.packages = lib.attrValues { inherit (pkgs) git; };

  programs.git = {
    enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      merge.conflictStyle = "diff3";
    };
    signing = {
      key = null;
      signByDefault = false;
    };
  };
}