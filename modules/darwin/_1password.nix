{ pkg
, pkgs
, lib
, ...
}:
{
  # nixpkgs.config = {
  #   allowUnfreePredicate =
  #     pkg:
  #     builtins.elem (lib.getName pkg) [
  #       "1password-gui"
  #       "_1password"
  #       "_1password-cli"
  #       "1password-cli"
  #     ];
  # };

  # environment.systemPackages = [
  #   # pkgs.vscode-extensions._1Password.op-vscode
  #   pkgs._1password
  # ];

  homebrew = {
    masApps = {
      "1Password for Safari" = 1569813296;
    };
    casks = [
      "1password"
      "1password-cli"
    ];
  };
}
