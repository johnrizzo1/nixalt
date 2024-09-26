{
  pkgs,
  ...
}: {
  networking.hostName = "tymnet";

  users.users.jrizzo.home = 
    if pkgs.stdenv.isDarwin
    then "/Users/jrizzo"
    else "/home/jrizzo";

  # users.users.root.home =
  #   if pkgs.stdenv.isDarwin
  #   then "/var/root"
  #   else "/root";
  
  nix.settings.experimental-features = "nix-command flakes";

  environment.systemPackages = with pkgs; [ hugo git-lfs ];

  # homebrew = {
  #   casks = [
  #     "sketch"
  #     "gimp"
  #     "krita"
  #     "figma"
  #     "blender"
  #     "inkscape"
  #     "gns3"
  #   ];
  # };

  # Set Git commit hash for darwin-version.
  # system.configurationRevision = self.rev or self.dirtyRev or null;
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 5;
}
