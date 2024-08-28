{
  ezModules,
  osConfig,
  ...
}: {
  programs.ssh.enable = true;

  home = {
    username = "root";
    # stateVersion = "24.05";
    homeDirectory = osConfig.users.users.root.home;
  };
}
