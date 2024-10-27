{ pkgs
, lib
, inputs
, ...
}:
let
  _extensions = with pkgs.vscode-extensions; [
    arrterian.nix-env-selector
    bbenoist.nix
    dracula-theme.theme-dracula
    mkhl.direnv
    jnoortheen.nix-ide
    vscodevim.vim
    yzhang.markdown-all-in-one
  ];
in
{
  home = {
    packages = with pkgs; [ spacevim ];

    shellAliases = {
      vi = "vim";
      # vim = "nvim";
    };

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };

  programs.vscode = {
    enable = true;
    # package = pkgs.vscodium.fhsWithPackages (
    # package = pkgs.vscode.fhsWithPackages (
    # ps: with ps; [ rustup zlib openssl.dev pkg-config ]
    # );
    package = pkgs.vscode;
    extensions = _extensions;
  };
}
