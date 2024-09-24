{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) optionals attrValues;
  pythonPkgs = ps:
    attrValues {
      inherit
        (ps)
        black
        flake8
        isort
        mypy
        pynvim
        debugpy
        pytest
        pandas
        requests
        jupyter
        ;
    };
in {
  home.packages =
    attrValues {
      inherit (pkgs)
        bat
        bottom
        cachix
        comma
        direnv
        erdtree
        eza
        gh
        glow
        jq
        google-chrome
        killall
        pandoc
        unzip
        wget
        zip
        ;
    } ++ [
      pkgs.nodePackages.pnpm
      (pkgs.python3.withPackages pythonPkgs)
    ] ++ optionals isLinux [
      pkgs.lldb
    ];
}
