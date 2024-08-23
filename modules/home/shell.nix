{
  config,
  osConfig,
  pkgs,
  lib,
  ezModules,
  ...
}: let
  inherit (osConfig.networking) hostName;
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (config.home) username;
in {
  imports = lib.attrValues {
    inherit (ezModules)
    carapace
    direnv
    git
    gpg
    # neovim
    ssh
    starship
    tmux
    zsh
    ;
  };

  home = {
    shellAliases =
      {
        # vim = "nvim";
        # direnv-init = ''echo "use flake" >> .envrc'';
        ".." = "cd ..";
        "..." = "cd ../..";
        top = "btm";
        btop = "btm";
        ls = "eza";
        cat = "bat -pp";
        tree = "erd --layout inverted --icons --human";
        homeSwitch = "home-manager switch --impure --flake '.#${username}@${hostName}'";
      } // (
        if isDarwin
        then { darwinSwitch = "darwin-rebuild switch --impure --flake '.#${hostName}'"; }
        else if isLinux
        then { nixosSwitch = "nixos-rebuild switch --impure --flake '.#${hostName}'"; }
        else {}
      );

    sessionVariables = {
      EDITOR = "vi";
      VISUAL = "vi";
    };
  };
}
