{ pkgs, lib, ... }: let
  _extensions = with pkgs.vscode-extensions; [
      arrterian.nix-env-selector
      bbenoist.nix
      dracula-theme.theme-dracula
      mkhl.direnv
      jnoortheen.nix-ide
      vscodevim.vim
      yzhang.markdown-all-in-one
  ]; # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [ ];
in {
  # imports = lib.attrValues [
    # inherit (ezModules)
    #   neovim
    #   ;
  # ]; 

  home.packages = with pkgs; [ spacevim ];

  programs.vscode = {
    enable = true;
    # package = pkgs.vscodium.fhsWithPackages (ps: with ps; [ rustup zlib ]);
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [ rustup zlib openssl.dev pkg-config ]);
    extensions = _extensions;
  };

  home.shellAliases = {
    vi = "spacevim";
    # vim = "nvim";
  };

  home.sessionVariables = {
    EDITOR="vim";
    VISUAL="vim";
  };
}
