{ pkgs
, currentSystemUser
, ...
}:
{
  imports = [
    ../modules/common/vm-shared.nix
  ];

  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = currentSystemUser;
    startMenuLaunchers = true;
  };

  # nix = {
  # package = pkgs.nixUnstable;
  # extraOptions = ''
  #   experimental-features = nix-command flakes
  #   keep-outputs = true
  #   keep-derivations = true
  # '';
  # };

  system.stateVersion = "24.05";
}
