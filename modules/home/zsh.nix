{
  config,
  pkgs,
  ...
}: let
  inherit
    (pkgs)
    zsh-nix-shell
    zsh-vi-mode
    nix-index
    ;
in {
  # programs.command-not-found.enable = true;
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    defaultKeymap = "viins"; # or viins, emacs, vicmd
    dotDir = ".config/zsh";
    enableCompletion = true;
    enableVteIntegration = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # enableLsColors = true;

    history = {
      ignoreSpace = true;
      ignoreAllDups = true;
      path = "${config.xdg.cacheHome}/zsh/history";
    };

    localVariables = {
      VI_MODE_RESET_PROMPT_ON_MODE_CHANGE = true;
      VI_MODE_SET_CURSOR = true;
    };

    completionInit = ''
      autoload -U compinit && compinit
      zstyle ':completion:*' menu select
      zmodload zsh/complist
      compinit
      _comp_options+=(globdots)  # Include hidden files.
      unsetopt completealiases   # Include aliases.
    '';

    initExtra = ''
      source ${zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
      source ${zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      # source ${nix-index}/etc/profile.d/command-not-found.sh
      # if [ "$TMUX" = "" ]; then
      #   exec tmux a
      # fi
    '';
  };
}
