{ pkgs
, currentSystemUser
, ...
}:
{
  imports = [
    # <nixos-wsl/modules>
    ../modules/nixos
    ../modules/nixos/vscode-server.nix
  ];

  environment.systemPackages = with pkgs; [
    devenv
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = currentSystemUser;
    startMenuLaunchers = true;
  };

  #######################################################################
  # Hardware configuration
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  programs.nix-ld.enable = true;
  services.vscode-server.enable = true;

  system.stateVersion = "25.05";
}
