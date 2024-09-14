{ pkgs, lib, ... }: {
  home.packages = lib.attrValues { inherit (pkgs) git git-lfs; };

  programs.git = {
    enable = true;
    delta.enable = true;
    lfs.enable = true;
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