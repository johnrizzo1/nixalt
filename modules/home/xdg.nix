{config, ...}: let
  inherit
    (config.xdg)
    cacheHome
    configHome
    dataHome
    ;
in {
  xdg = {
    enable = true;
    configFile = {
      # "nixpkgs/config.nix".source = config;
      "python/pythonrc.py".text = ''
        import atexit
        import os
        import readline

        history = os.path.join(os.environ["XDG_CACHE_HOME"], "python_history")
        try:
            readline.read_history_file(history)
        except OSError:
            pass


        def write_history():
            try:
                readline.write_history_file(history)
            except OSError:
                pass


        atexit.register(write_history)
      '';
      "mypy/config".text = ''
        [mypy]
        python_version = 3.10
        strict = True
        no_implicit_optional = False
      '';
      "lazygit/config.yml".text = ''
        git:
          autoFetch: false
      '';
  };

  };
  home = {
    sessionVariables = {
      GHCUP_USE_XDG_DIRS = 1; # $HOME/.ghcup
      PYTHONSTARTUP = "${configHome}/python/pythonrc.py"; # $HOME/.python_history
      LESSHISTFILE = "${cacheHome}/less/history"; # $HOME/.lesshst
      KDEHOME = "${configHome}/kde"; # $HOME/.kde4
      # GTK2_RC_FILES = "${configHome}/gtk-2.0/gtkrc"; # $HOME/.gtkrc-2.0
      GNUPGHOME = "${dataHome}/gnupg"; # $HOME/.gnupg
      CUDA_CACHE_PATH = "${cacheHome}/nv"; # $HOME/.nv
      INPUTRC = "${configHome}/readline/inputrc"; # $HOME/.inputrc
      # AWS_SHARED_CREDENTIALS_FILE = "${configHome}/aws/credentials";
      # AWS_CONFIG_FILE = "${configHome}/aws/config";
      DOCKER_CONFIG = "${configHome}/docker"; # $HOME/.docker
    };
    shellAliases = {
      # yarn = "yarn --use-yarnrc ${configHome}/yarn/config"; # $HOME/.yarnrc
      wget = "wget - -hsts-file=${dataHome}/wget-hsts"; # $HOME/wget-hsts
    };
  };
}

  