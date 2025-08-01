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
    # Home-manager 22.11 requires this be set. We never set it so we have
    # to use the old state version.
    stateVersion = "24.05";

    # Packages I always want installed. Most packages I install using
    # per-project flakes sourced with direnv and nix-shell, so this is
    # not a huge list.
    packages = with pkgs; [
      # jdk
      ansible
      ansible-lint
      asciinema
      bat
      bottom
      comma
      devbox
      dotnet-aspnetcore
      dotnet-sdk
      emacs
      eslint
      eza
      fd
      fh
      fzf
      gh
      git
      git-lfs
      gitflow
      gnumake
      gopls
      htop
      jq
      killall
      lsof
      nil
      niv
      nixd
      nixos-generators
      nmap
      unstable.node2nix
      nodejs # Node is required for Copilot.vim
      packer
      poetry
      poetryPlugins.poetry-plugin-shell
      postgresql
      postman
      procs
      puppeteer-cli
      temurin-bin
      xorg.libXext
      (python3.withPackages (ps: with ps; [
        black
        flake8
        huggingface-hub
        isort
        mypy
        pip
        pip-tools
        pipx
        pylint
        pytest
        pytest-cov
        pytest-xdist
        ruff
        tensorflow
        torch
      ]))
      ripgrep
      (ruby.withPackages (ps: with ps; [
        rubocop
        solargraph
      ]))
      # unstable.devenv
      # unstable.direnv
      spacevim
      tailscale
      terraform-lsp
      tmux
      tree
      unetbootin
      uv
      vagrant
      vim
      watch
      weechat
      wget
      xclip
      xsel
      zenith
    ] ++ (lib.optionals (isLinux && !isWSL) [ ]);

    #---------------------------------------------------------------------
    # Env vars and dotfiles
    #---------------------------------------------------------------------
    sessionPath = [
      "/opt/homebrew/bin"
      "/opt/homebrew/sbin"
      # "/opt/anaconda3/bin"
      "${cacheHome}/.npm-global/bin"
    ];

    sessionVariables = {
      AWS_CONFIG_FILE = "${configHome}/aws/config";
      AWS_SHARED_CREDENTIALS_FILE = "${configHome}/aws/credentials";
      DIRENV_LOG_FORMAT = ""; # Disable direnv logging
      DOCKER_CONFIG = "${configHome}/docker"; # $HOME/.docker
      EDITOR = "nvim";
      GHCUP_USE_XDG_DIRS = 1; # $HOME/.ghcup
      GNUPGHOME = "${dataHome}/gnupg"; # $HOME/.gnupg
      INPUTRC = "${configHome}/readline/inputrc"; # $HOME/.inputrc
      KDEHOME = "${configHome}/kde"; # $HOME/.kde4
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LESSHISTFILE = "${cacheHome}/less/history"; # $HOME/.lesshst
      NIXOS_OZONE_WL = 1;
      NPM_CONFIG_PREFIX="${cacheHome}/.npm-global";
      PAGER = "less -FirSwX";
      PYTHONSTARTUP = "${configHome}/python/pythonrc.py"; # $HOME/.python_history
      SSH_AUTH_SOCK = "/home/jrizzo/.1password/agent.sock"; # $HOME/.1password/agent.sock
    } // (lib.optionalAttrs isWSL {
      CUDA_CACHE_PATH = "${cacheHome}/nv"; # $HOME/.nv
      CUDA_PATH = "${pkgs.cudatoolkit}";
      EXTRA_CCFLAGS = "-I/usr/include";
      EXTRA_LDFLAGS = "-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib";
      LD_LIBRARY_PATH = "/usr/lib/wsl/lib:${pkgs.linuxPackages.nvidia_x11}/lib:${pkgs.ncurses5}/lib:$LD_LIBRARY_PATH";
      KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";
    # }) // (lib.optionalAttrs isLinux {
    #   # This is required for the 1Password CLI to work properly.
    #   SSH_AUTH_SOCK = "${dataHome}/.1password/agent.sock"; # $HOME/.1password/agent.sock
    }) // (lib.optionalAttrs isDarwin {
      # This is required for the 1Password CLI to work properly.
      SSH_AUTH_SOCK = "${dataHome}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    });

    shellAliases =
      {
        "..." = "cd ../..";
        ".." = "cd ..";
        btop = "btm";
        cat = "bat -pp";
        # claude = "/Users/jrizzo/.claude/local/claude";
        ga = "git add";
        gc = "git commit";
        gcli = "npx https://github.com/google-gemini/gemini-cli";
        gco = "git checkout";
        gcp = "git cherry-pick";
        gdiff = "git diff";
        gl = "git prettylog";
        gp = "git push";
        gs = "git status";
        gt = "git tag";
        ls = "eza";
        ll = "ls -l";
        tf = "terraform";
        tfc = "terraform console";
        tg = "terragrunt";
        top = "btm";
        tree = "erd --layout inverted --icons --human";
        wget = "wget - -hsts-file=${dataHome}/wget-hsts"; # $HOME/wget-hsts
        yarn = "yarn --use-yarnrc ${configHome}/yarn/config"; # $HOME/.yarnrc
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
  };

  #---------------------------------------------------------------------
  # Setting up config files
  #---------------------------------------------------------------------
  xdg.enable = true;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------
  programs = {

    home-manager = {
      enable = true;
    };

    bash = {
      enable = true;
      shellOptions = [ ];
      enableCompletion = true;
      historyControl = [
        "ignoredups"
        "ignorespace"
      ];
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      # enableFishIntegration = true;
      # nix-direnv.enable = pkgs.stdenv.isLinux;
      nix-direnv.enable = true;
      config = {
        load_dotenv = true;
        hide_env_diff = true;
        whitelist = {
          exact = [ "$HOME/.envrc" ];
        };
      };
    };

    fish = {
      enable = true;
    };

    tmux = {
      enable = true;
      aggressiveResize = true;
      mouse = false;
      keyMode = "vi";
      prefix = "C-a";
      package = pkgs.tmux;
      baseIndex = 1;
      escapeTime = 0;

      # These customize the sensible plugin
      extraConfig = ''
        set-option -g status-position top
        bind -n C-l send-keys "clear"\; send-keys "Enter"
        bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
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

      initContent = ''
        if command -v fh &> /dev/null; then
          eval "$(fh completion zsh)"
        fi
      '';
    };
    dircolors.enableZshIntegration = true;
    eza.enableZshIntegration = true;
    fzf.enable = true;
    fzf.enableZshIntegration = true;

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
          extraOptions = {
            "IdentityAgent" = if pkgs.stdenv.isDarwin then
              "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
            else
              "~/.1password/agent.sock";
          };
        };
      };

      # startAgent = true;
      controlMaster = "auto";
      forwardAgent = false;
      compression = true;
      # extraConfig =
      #   if pkgs.stdenv.isDarwin then ''
      #     IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
      #   '' else ''
      #     IdentityAgent "/home/jrizzo/.1password/agent.sock"
      #   '';
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

  #######################################################################
  # dconf settings
  dconf.enable = true;
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };

}
