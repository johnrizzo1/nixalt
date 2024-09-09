{
  pkgs,
  ...
}: {
  networking.hostName = "tymnet";

  users.users.jrizzo.home = 
    if pkgs.stdenv.isDarwin
    then "/Users/jrizzo"
    else "/home/jrizzo";

  users.users.root.home =
    if pkgs.stdenv.isDarwin
    then "/var/root"
    else "/root";
  
  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.systemPackages = with pkgs; [ hugo git-lfs ];

  homebrew = {
    casks = [
      "sketch"
      "gimp"
      "krita"
      "figma"
      "blender"
      "inkscape"
      "gns3"
    ];
  };
}
