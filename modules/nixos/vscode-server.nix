{ inputs, ... }: {
  imports = [
    inputs.vscode-server.nixosModules.default
  ];

  services.vscode-server.enable = true;
  # Don't forget to run the following to enable the service
  # systemctl --user enable auto-fix-vscode-server.service
  # systemctl --user start auto-fix-vscode-server.service
  # FIX: ln -sfT /run/current-system/etc/systemd/user/auto-fix-vscode-server.service ~/.config/systemd/user/auto-fix-vscode-server.service
  # vscode-server.enable = true;
  # vscode-server.enableFHS = true;
}
