{
  isWSL,
  inputs,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (pkgs) tmuxPlugins;
  inherit (config.xdg) cacheHome configHome dataHome;
  # sources = import ../../nix/sources.nix;
  inherit (pkgs.stdenv) isDarwin isLinux;
  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  # manpager = (pkgs.writeShellScriptBin "manpager" (if isDarwin then ''
  #   sh -c 'col -bx | bat -l man -p'
  #   '' else ''
  #   cat "$1" | col -bx | bat --language man --style plain
  # ''));
in {
  imports = [
    #   # catppuccin
    #   ./editor.nix
    #   ./home-manager.nix
    #   ./packages.nix
    #   ./shell.nix
    #   ./xdg.nix
    # ./obs.nix
    #   ./git.nix
  ];

  home = {
    # Home-manager 22.11 requires this be set. We never set it so we have
    # to use the old state version.
    stateVersion = "24.05";

    #---------------------------------------------------------------------
    # Packages
    #---------------------------------------------------------------------

    # Packages I always want installed. Most packages I install using
    # per-project flakes sourced with direnv and nix-shell, so this is
    # not a huge list.
    packages = with pkgs;
      [
        _1password
        # alpaca # ollama GUI
        # android-studio-full
        # ripgrep
        # sentry-cli
        # zigpkgs."0.13.0"
        asciinema
        bat
        bottom
        comma
        eza
        fd
        fzf
        gh
        git
        git-lfs
        gnumake
        gopls
        htop
        jq
        killall
        niv
        nodejs # Node is required for Copilot.vim
        procs
        tailscale
        tmux
        tree
        vim
        watch
        weechat
        wget
        xclip
        xsel
        zenith
        spacevim
      ]
      ++ (lib.optionals (isLinux && !isWSL) [
        _1password-gui
        chromium
        discord
        element-desktop-wayland
        firefox
        freetube
        rxvt_unicode
        signal-desktop
        spotube
        synology-drive-client
        vscodium
      ]);

    #---------------------------------------------------------------------
    # Env vars and dotfiles
    #---------------------------------------------------------------------

    sessionVariables = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      EDITOR = "nvim";
      PAGER = "less -FirSwX";
      # MANPAGER = "${manpager}/bin/manpager";

      # XDG Config Dirs
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

    shellAliases =
      {
        ".." = "cd ..";
        "..." = "cd ../..";
        top = "btm";
        btop = "btm";
        ls = "eza";
        cat = "bat -pp";
        tree = "erd --layout inverted --icons --human";
        ga = "git add";
        gc = "git commit";
        gco = "git checkout";
        gcp = "git cherry-pick";
        gdiff = "git diff";
        gl = "git prettylog";
        gp = "git push";
        gs = "git status";
        gt = "git tag";

        jf = "jj git fetch";
        jn = "jj new";
        js = "jj st";

        # XDG Config Dirs
        # yarn = "yarn --use-yarnrc ${configHome}/yarn/config"; # $HOME/.yarnrc
        wget = "wget - -hsts-file=${dataHome}/wget-hsts"; # $HOME/wget-hsts
      }
      // (
        if isLinux
        then {
          # Two decades of using a Mac has made this such a strong memory
          # that I'm just going to keep it consistent.
          pbcopy = "xclip";
          pbpaste = "xclip -o";
        }
        else {}
      );
  };

  #---------------------------------------------------------------------
  # Setting up config files
  #---------------------------------------------------------------------
  xdg.enable = true;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs = {
    bash = {
      enable = true;
      shellOptions = [];
      enableCompletion = true;
      historyControl = ["ignoredups" "ignorespace"];
      initExtra = builtins.readFile ./files/bashrc;

      shellAliases = {
        ga = "git add";
        gc = "git commit";
        gco = "git checkout";
        gcp = "git cherry-pick";
        gdiff = "git diff";
        gl = "git prettylog";
        gp = "git push";
        gs = "git status";
        gt = "git tag";
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      # enableFishIntegration = true;
      config = {
        whitelist = {
          # prefix= [
          #   "$HOME/code/go/src/github.com/hashicorp"
          #   "$HOME/code/go/src/github.com/mitchellh"
          # ];

          exact = ["$HOME/.envrc"];
        };
      };
    };

    fish = {
      enable = true;
      interactiveShellInit = lib.strings.concatStrings (lib.strings.intersperse "\n" [
        (builtins.readFile ./files/config.fish)
        "set -g SHELL ${pkgs.fish}/bin/fish"
      ]);

      # shellAliases = {};

      # plugins = [
      #   "fish-fzf"
      #   "fish-foreign-env"
      #   "theme-bobthefish"
      # ];
    };

    tmux = {
      enable = true;
      baseIndex = 1;
      clock24 = true;
      mouse = true;
      newSession = true;
      terminal = "screen-256color";
      prefix = "C-a";
      keyMode = "vi";
      # shortcut = "l";
      # secureSocket = false;

      extraConfig = ''
        set-option -g status-position top

        # Opens new windows in the current directory
        bind '"' split-window -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        set -s set-clipboard external
        set -s copy-command 'xsel -i'

        # Vim style pane selection
        set -g status-keys vi
        setw -g mode-keys vi
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Fix my clear screen obsession
        bind-key -n C-l send-keys -R ^M \; clear-history
      '';

      plugins = [
        {
          plugin = tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-dir ${config.xdg.stateHome}/tmux-ressurect
            set -g @resurrect-strategy-nvim 'session'
          '';
        }
        {
          plugin = tmuxPlugins.yank;
          extraConfig = ''
            set -g @yank_action 'copy-pipe'
          '';
        }
        {
          plugin = tmuxPlugins.catppuccin.overrideAttrs (_: {
            version = "unstable-2023-11-01";
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "tmux";
              rev = "47e33044b4b47b1c1faca1e42508fc92be12131a";
              hash = "sha256-kn3kf7eiiwXj57tgA7fs5N2+B2r441OtBlM8IBBLl4I=";
            };
          });
          extraConfig = ''
            set -g @catppuccin_flavour 'frappe'

            set -g @catppuccin_window_left_separator ""
            set -g @catppuccin_window_right_separator " "
            set -g @catppuccin_window_middle_separator " █"
            set -g @catppuccin_window_number_position "right"

            set -g @catppuccin_window_default_fill "number"
            set -g @catppuccin_window_default_text "#W"

            set -g @catppuccin_window_current_fill "number"
            set -g @catppuccin_window_current_text "#W"

            set -g @catppuccin_status_modules_right "session date_time"
            set -g @catppuccin_status_left_separator  " "
            set -g @catppuccin_status_right_separator ""
            set -g @catppuccin_status_right_separator_inverse "no"
            set -g @catppuccin_status_fill "icon"
            set -g @catppuccin_status_connect_separator "no"

            set -g @catppuccin_date_time_text "%a %-d %b %H:%M"
          '';
        }
        tmuxPlugins.sensible
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.resurrect
        tmuxPlugins.open
        tmuxPlugins.continuum
        tmuxPlugins.tmux-fzf
      ];
    };

    zsh = {
      enable = true;
      # enableBashCompletion = true;
      enableCompletion = true;
      # enableFzfCompletion = true;
      syntaxHighlighting.enable = true;
    };

    git = {
      enable = true;
      userName = "John Rizzo";
      userEmail = "johnrizzo1@gmail.com";
      # signing = {
      #   key = "523D5DC389D273BC";
      #   signByDefault = true;
      # };
      aliases = {
        # cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
        prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
        root = "rev-parse --show-toplevel";
      };
      extraConfig = {
        branch.autosetuprebase = "always";
        color.ui = true;
        core.askPass = ""; # needs to be empty to use terminal for ask pass
        credential.helper = "store"; # want to make this more secure
        delta.enable = true;
        github.user = "johnrizzo1";
        init.defaultBranch = "main";
        lfs.enable = true;
        merge.conflictStyle = "diff3";
        push.default = "tracking";
      };
    };

    go = {
      enable = true;
      goPath = "Projects/go";
      goPrivate = ["github.com/johnrizzo1" "rfc822.mx"];
    };

    jujutsu = {
      enable = true;

      # I don't use "settings" because the path is wrong on macOS at
      # the time of writing this.
    };

    ssh = {
      enable = true;

      matchBlocks = {
        "coda" = lib.hm.dag.entryBefore ["*"] {
          hostname = "coda";
          forwardAgent = true;
        };
        "irl" = lib.hm.dag.entryBefore ["coda"] {
          hostname = "irl";
          forwardAgent = true;
        };
      };

      # startAgent = true;
      controlMaster = "auto";
      forwardAgent = false;
      compression = true;

      extraConfig =
        if pkgs.stdenv.isDarwin
        then "IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
        else "";
    };

    alacritty = {
      enable = !isWSL;

      settings = {
        env.TERM = "xterm-256color";

        window.dimensions = {
          columns = 130;
          lines = 36;
        };

        font = {
          italic.style = "Italic";
          bold.style = "Bold";
          bold_italic.style = "Bold Italic";
          size =
            if isLinux
            then 13
            else 15;

          normal = {
            family = "CaskaydiaCove Nerd Font";
            style = "Regular";
          };
        };

        keyboard.bindings = [
          {
            key = "K";
            mods = "Command";
            chars = "ClearHistory";
          }
          {
            key = "V";
            mods = "Command";
            action = "Paste";
          }
          {
            key = "C";
            mods = "Command";
            action = "Copy";
          }
          {
            key = "Key0";
            mods = "Command";
            action = "ResetFontSize";
          }
          {
            key = "Equals";
            mods = "Command";
            action = "IncreaseFontSize";
          }
          # { key = "Subtract"; mods = "Command"; action = "DecreaseFontSize"; }
        ];
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
    };

    # command-not-found.enable = true;
    nix-index = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    # kitty = {
    #   enable = !isWSL;
    #   extraConfig = builtins.readFile ./kitty;
    # };

    i3status = {
      enable = isLinux && !isWSL;

      general = {
        colors = true;
        color_good = "#8C9440";
        color_bad = "#A54242";
        color_degraded = "#DE935F";
      };

      modules = {
        ipv6.enable = false;
        "wireless _first_".enable = false;
        "battery all".enable = false;
      };
    };

    neovim = {
      enable = true;
      # package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

      withPython3 = true;

      # plugins = with pkgs; [
      #   customVim.vim-copilot
      #   customVim.vim-cue
      #   customVim.vim-fish
      #   customVim.vim-glsl
      #   customVim.vim-misc
      #   customVim.vim-pgsql
      #   customVim.vim-tla
      #   customVim.vim-zig
      #   customVim.pigeon
      #   customVim.AfterColors

      #   customVim.vim-nord
      #   customVim.nvim-comment
      #   customVim.nvim-conform
      #   customVim.nvim-dressing
      #   customVim.nvim-gitsigns
      #   customVim.nvim-lualine
      #   customVim.nvim-lspconfig
      #   customVim.nvim-nui
      #   customVim.nvim-plenary # required for telescope
      #   customVim.nvim-telescope
      #   customVim.nvim-treesitter
      #   customVim.nvim-treesitter-playground
      #   customVim.nvim-treesitter-textobjects

      #   vimPlugins.vim-eunuch
      #   vimPlugins.vim-markdown
      #   vimPlugins.vim-nix
      #   vimPlugins.typescript-vim
      #   vimPlugins.nvim-treesitter-parsers.elixir
      # ] ++ (lib.optionals (!isWSL) [
      #   # This is causing a segfaulting while building our installer
      #   # for WSL so just disable it for now. This is a pretty
      #   # unimportant plugin anyway.
      #   customVim.nvim-web-devicons
      # ]);

      # extraConfig = (import ./vim-config.nix) { inherit sources; };
    };
  };
}
