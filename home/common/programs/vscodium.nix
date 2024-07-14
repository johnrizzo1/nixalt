{pkgs, ...}: {
  # for extension updates
  # ./nixpkgs/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh
  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    #mutableExtensionsDir = false;
    mutableExtensionsDir = true;
    package = pkgs.vscodium.fhs;
    # package = pkgs.vscodium.fhsWithPackages (ps: with ps; [ rustup zlib ]);

    # Extensions
    extensions = with pkgs.vscode-extensions; [
      # Stable

      mhutchie.git-graph
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      oderwat.indent-rainbow
      pkief.material-icon-theme
      seatonjiang.gitmoji-vscode
      visualstudioexptteam.vscodeintellicode
      vscodevim.vim
      yzhang.markdown-all-in-one

      #
      # Nix
      bierner.emojisense
      bierner.markdown-emoji
      jnoortheen.nix-ide
      # pinage404.nix-extension-pack
      arrterian.nix-env-selector
      # edwinkofler.vscode-hyperupcall-pack-unix
      bbenoist.nix
      mkhl.direnv
      thenuprojectcontributors.vscode-nushell-lang
      ms-vscode.makefile-tools
      # timonwong.shell
      mads-hartmann.bash-ide-vscode
      # jeff-hykin.better-shellscript-syntax
      # kamadorueda.ale

      #
      # Python
      ms-python.debugpy
      ms-python.python
      ms-python.vscode-pylance
      ms-toolsai.jupyter
      ms-toolsai.jupyter-keymap
      ms-toolsai.jupyter-renderers
      ms-toolsai.vscode-jupyter-cell-tags
      ms-toolsai.vscode-jupyter-slideshow
    ];
    # TODO Fix this
    # ]) ++ (with pkgs.unstable.vscode-extensions; [
    #   # Unstable
    #   seatonjiang.gitmoji-vscode
    # ]);

    # Settings
    # userSettings = {
    # # General
    # "editor.fontSize" = 12;
    # "editor.fontFamily" = "'Jetbrains Mono', 'monospace', monospace";
    # "editor.minimap.enabled" = false;
    # "terminal.integrated.fontSize" = 12;
    # "terminal.integrated.fontFamily" = "'JetBrainsMono Nerd Font', 'monospace', monospace";
    # "window.zoomLevel" = 1;
    # "editor.multiCursorModifier" = "ctrlCmd";
    # "workbench.startupEditor" = "none";
    # "explorer.compactFolders" = false;
    # # Whitespace
    # "files.trimTrailingWhitespace" = true;
    # "files.trimFinalNewlines" = true;
    # "files.insertFinalNewline" = true;
    # "diffEditor.ignoreTrimWhitespace" = false;
    # # Git
    # "git.enableCommitSigning" = false;
    # "git-graph.repository.sign.commits" = true;
    # "git-graph.repository.sign.tags" = true;
    # "git-graph.repository.commits.showSignatureStatus" = true;
    # "git.autofetch" = true;
    # # Styling
    # "window.autoDetectColorScheme" = true;
    # "workbench.preferredDarkColorTheme" = "Default Dark Modern";
    # "workbench.preferredLightColorTheme" = "Default Light Modern";
    # "workbench.iconTheme" = "material-icon-theme";
    # "material-icon-theme.activeIconPack" = "none";
    # "material-icon-theme.folders.theme" = "classic";
    # # Other
    # "telemetry.telemetryLevel" = "off";
    # "update.showReleaseNotes" = false;
    # # Gitmoji
    # "gitmoji.onlyUseCustomEmoji" = true;
    # "gitmoji.addCustomEmoji" = [
    # {
    # "emoji" = "📦 NEW:";
    # "code" = ":package: NEW:";
    # "description" = "... Add new code/feature";
    # }
    # {
    # "emoji" = "👌 IMPROVE:";
    # "code" = ":ok_hand: IMPROVE:";
    # "description" = "... Improve existing code/feature";
    # }
    # {
    # "emoji" = "❌ REMOVE:";
    # "code" = ":x: REMOVE:";
    # "description" = "... Remove existing code/feature";
    # }
    # {
    # "emoji" = "🐛 FIX:";
    # "code" = ":bug: FIX:";
    # "description" = "... Fix a bug";
    # }
    # {
    # "emoji" = "📑 DOC:";
    # "code" = ":bookmark_tabs: DOC:";
    # "description" = "... Anything related to documentation";
    # }
    # {
    # "emoji" = "🤖 TEST:";
    # "code" = ":robot: TEST:";
    # "description" = "... Anything realted to tests";
    # }
    # ];
    # };
  };
}
