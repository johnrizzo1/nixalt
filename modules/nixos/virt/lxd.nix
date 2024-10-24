{...}: {
  virtualisation.incus.enable = true;

  virtualisation.lxd = {
    enable = true;
    agent.enable = true;
    ui.enable = true;
    recommendedSysctlSettings = true;
  };
  virtualisation.lxc = {
    enable = true;
    lxcfs.enable = true;
  };
}
