{ ... }: {
  virtualisation.lxd = {
    enable = true;
    ui.enable = true;
    recommendedSysctlSettings = true;
  };
  virtualisation.lxc = {
    enable = true;
    lxcfs.enable = true;
  };
}