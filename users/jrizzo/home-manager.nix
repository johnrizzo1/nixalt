{ isWSL
, inputs
, ...
}:
{ config
, lib
, pkgs
, ...
}:
let
  inherit (pkgs) tmuxPlugins;
  inherit (config.xdg) cacheHome configHome dataHome;
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  home = {
    #---------------------------------------------------------------------
    # Packages
    #---------------------------------------------------------------------
    # useGlobalPkgs = true;

    # Packages I always want installed. Most packages I install using
    # per-project flakes sourced with direnv and nix-shell, so this is
    # not a huge list.
    packages =
      with pkgs;
      [
        _1password-cli
        asciinema
        bat
        bottom
        cachix
        comma
        devenv
        direnv
        eza
        fd
        fh
        fzf
        gh
        git
        git-lfs
        gnumake
        gopls
        home-manager
        htop
        jq
        killall
        niv
        nixd
        nmap
        nodejs # Node is required for Copilot.vim
        mosh
        procs
        spacevim
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
      ];

    #---------------------------------------------------------------------
    # Env vars and dotfiles
    #---------------------------------------------------------------------

    sessionPath = [
      "/usr/local/bin"
    ] ++ lib.optionals pkgs.stdenv.isDarwin [
      "/opt/anaconda3/bin"
      "/opt/homebrew/bin"
    ];

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
      INPUTRC = "${configHome}/readline/inputrc"; # $HOME/.inputrc
      # AWS_SHARED_CREDENTIALS_FILE = "${configHome}/aws/credentials";
      # AWS_CONFIG_FILE = "${configHome}/aws/config";
      DOCKER_CONFIG = "${configHome}/docker"; # $HOME/.docker
      NIXOS_OZONE_WL = 1;
    };

    shellAliases =
      {
        "..." = "cd ../..";
        ".." = "cd ..";
        btop = "btm";
        cat = "bat -pp";
        ga = "git add";
        gc = "git commit";
        gco = "git checkout";
        gcp = "git cherry-pick";
        gdiff = "git diff";
        gl = "git prettylog";
        gp = "git push";
        gs = "git status";
        gt = "git tag";
        ls = "eza";
        ll = "ls -l";
        tg = "terragrunt";
        top = "btm";
        tree = "erd --layout inverted --icons --human";
        wget = "wget - -hsts-file=${dataHome}/wget-hsts"; # $HOME/wget-hsts
        yarn = "yarn --use-yarnrc ${configHome}/yarn/config"; # $HOME/.yarnrc
        docker = "podman";
      }
      // (
        if isLinux then
          {
            # Two decades of using a Mac has made this such a strong memory
            # that I'm just going to keep it consistent.
            pbcopy = "xclip";
            pbpaste = "xclip -o";
          }
        else
          { }
      );

    # Home-manager 22.11 requires this be set. We never set it so we have
    # to use the old state version.
    stateVersion = "24.05";
  };

  #---------------------------------------------------------------------
  # Setting up config files
  #---------------------------------------------------------------------
  xdg.enable = true;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------
  programs = {
    home-manager.enable = true;

    bash = {
      enable = true;
      shellOptions = [ ];
      enableCompletion = true;
      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
    };

    dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      # enableFishIntegration = true;
      # nix-direnv.enable = true;
      silent = true;
      config = {
        load_dotenv = true;
        whitelist = {
          exact = [ "$HOME/.envrc" ];
        };
      };
    };

    fish.enable = true;

    tmux = {
      enable = true;
      aggressiveResize = true;
      baseIndex = 1;
      escapeTime = 0;
      keyMode = "vi";
      mouse = false;
      package = pkgs.tmux;
      prefix = "C-a";
      sensibleOnTop = true;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "screen-256color";

      # These customize the sensible plugin
      extraConfig = ''
        set-option -g status-position top
        bind -n C-l send-keys "clear"\; send-keys "Enter"
        bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
        set -g default-command ${pkgs.zsh}/bin/zsh
      '';

      plugins = [
        {
          plugin = tmuxPlugins.yank;
          extraConfig = ''
            set -g @yank_action 'copy-pipe'
          '';
        }
        {
          plugin = tmuxPlugins.catppuccin;
          extraConfig = ''
            set -g @catppuccin_flavour 'frappe' # latte macchiato mocha frappe
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
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.tmux-fzf
      ];
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      syntaxHighlighting.enable = true;
      autosuggestion.enable = true;

      initExtra = ''
        if command -v fh &> /dev/null; then
          eval "$(fh completion zsh)"
        fi
      '';
    };
    eza.enableZshIntegration = true;
    fzf.enable = true;
    fzf.enableZshIntegration = true;
    fzf.enableBashIntegration = true;
    fzf.enableFishIntegration = true;

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

    ssh = {
      enable = true;

      matchBlocks = {
        "coda" = lib.hm.dag.entryBefore [ "*" ] {
          hostname = "coda";
          forwardAgent = true;
        };
        "irl" = lib.hm.dag.entryBefore [ "coda" ] {
          hostname = "irl";
          forwardAgent = true;
        };
      };

      # startAgent = true;
      controlMaster = "auto";
      forwardAgent = false;
      compression = true;

      extraConfig =
        if pkgs.stdenv.isDarwin then ''
          Host *
            IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
        '' else ''
          Host *
            IdentityAgent "~/.1password/agent.sock";
        '';
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
          size = if isLinux then 13 else 15;

          normal = {
            # family = "CaskaydiaCove Nerd Font";
            family = "AnonymicePro Nerd Font";
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
      enableBashIntegration = true;
      enableNushellIntegration = true;
    };

    # command-not-found.enable = true;
    nix-index = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
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
