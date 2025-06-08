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
    cudatoolkit
    linuxPackages.nvidia_x11
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

  services.vscode-server.enable = true;
  programs.nix-ld.enable = true;
  system.stateVersion = "25.05";
}
