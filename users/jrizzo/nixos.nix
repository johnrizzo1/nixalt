{ pkgs, inputs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Since we're using fish as our shell
  programs.fish.enable = true;

  users.users.jrizzo = {
    isNormalUser = true;
    home = "/home/jrizzo";
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "docker"
      "lxd"
      "incus-admin"
      "gns3"
    ];
    shell = pkgs.fish;
    hashedPassword = "$y$j9T$b5Q1pCL/pua.UUsOV3TKi/$8nkwFkKrHjUu5cr8b4TQnFgSpcYbVuFW63w88UppUF1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRWDuga9nU4wD0HFVQ1Xe66qSGZExVqWfhXWD7fk9E2"
    ];
  };

  # nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #   (import ./vim.nix { inherit inputs; })
  # ];
}
