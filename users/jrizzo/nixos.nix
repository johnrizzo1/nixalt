{ pkgs
, inputs
, ...
}:
{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/fish" "/share/zsh" ];

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # environment.systemPackages = with pkgs; [];
  # home.packages = with pkgs; [];

  programs.fish.enable = true;
  programs.zsh.enable = true;
  # programs.bash.enable = true; # No longer does anything

  users.users.jrizzo = {
    isNormalUser = true;
    home = "/home/jrizzo";
    extraGroups = [
      "docker"
      "gns3"
      "incus-admin"
      "libvirtd"
      "lxd"
      "networkmanager"
      "wheel"
      "kvm"
    ];
    shell = pkgs.zsh;
    hashedPassword = "$y$j9T$b5Q1pCL/pua.UUsOV3TKi/$8nkwFkKrHjUu5cr8b4TQnFgSpcYbVuFW63w88UppUF1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIRWDuga9nU4wD0HFVQ1Xe66qSGZExVqWfhXWD7fk9E2"
    ];
  };

  # nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #   (import ./vim.nix { inherit inputs; })
  # ];
}
