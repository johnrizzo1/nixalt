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
    (python3.withPackages (python-pkgs: with python-pkgs; [
      torch
      torchaudio
      torchvision
    ]))
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

  system.stateVersion = "24.05";
}
