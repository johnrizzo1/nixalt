{ inputs, pkgs, ... }:
{
  # environment.systemPackages = [ ];
  # home.packages = with pkgs; [ ];
  users.users = {
    jrizzo = {
      name = "jrizzo";
      home = "/Users/jrizzo";
      shell = pkgs.zsh;
    };
  };

  # homebrew = {
  #   enable = true;
  #   brews = [ ];
  #   masApps = {};
  #   casks = [ ];
  # };
}
