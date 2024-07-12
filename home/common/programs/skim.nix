{ ... }: {
  # skim provides a single executable: sk.
  # Basically anywhere you would want to use grep, try sk instead.
  programs.skim = {
    enable = true;
    enableBashIntegration = true;
  };
}
