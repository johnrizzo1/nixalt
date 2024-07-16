{
  ezModules,
  osConfig,
  ...
}: {
  # imports = [
  #   ezModules.builder-ssh
  # ];

  programs.ssh.enable = true;

  home = {
    username = "root";
    homeDirectory = osConfig.users.users.root.home;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
