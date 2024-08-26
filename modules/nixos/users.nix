{pkgs, ... }: let
  inherit (pkgs.stdenv) isDarwin;
in {
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jrizzo = {
    isNormalUser = true;
    description = "John Rizzo";
    extraGroups = [ "networkmanager" "wheel" "libvirtd"];
    packages = with pkgs; [ ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.home = if isDarwin then "/var/root" else "/root";
}