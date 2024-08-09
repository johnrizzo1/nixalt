{
  config,
  osConfig,
  pkgs,
  ...
}: let
  inherit (osConfig.networking) hostName;
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (config.home) username;

  homeSwitch = "home-manager switch --impure --flake '.#${username}@${hostName}'";
  nixosSwitch = "nixos-rebuild switch --impure --flake '.#${hostName}'";
  darwinSwitch = "darwin-rebuild switch --impure --flake '.#${hostName}'";
in {
  home = {
    packages = [pkgs.powershell];

    shellAliases =
      {
        inherit homeSwitch;

        vim = "nvim";
        direnv-init = ''echo "use flake" >> .envrc'';
        ".." = "cd ..";
        "..." = "cd ../..";
        top = "btm";
        btop = "btm";
        ls = "eza";
        cat = "bat -pp";
        tree = "erd --layout inverted --icons --human";
      }
      // (
        if isDarwin
        then {inherit darwinSwitch;}
        else if isLinux
        then {inherit nixosSwitch;}
        else {}
      );

    sessionVariables = {
      EDITOR = "vi";
      VISUAL = "vi";
    };
  };

  xdg.configFile."powershell/Microsoft.PowerShell_profile.ps1".text = ''
    Invoke-Expression (&starship init powershell)
    Set-PSReadlineOption -EditMode Vi -ViModeIndicator Cursor
  '';
}
