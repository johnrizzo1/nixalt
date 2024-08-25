{ pkgs, ... }: {
  packages = [pkgs.powershell];
  xdg.configFile."powershell/Microsoft.PowerShell_profile.ps1".text = ''
    Invoke-Expression (&starship init powershell)
    Set-PSReadlineOption -EditMode Vi -ViModeIndicator Cursor
  '';
}