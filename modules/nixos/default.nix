{ lib, ... }:
{
  imports = [
    ../common/nix.nix
    ../common/nixpkgs.nix
    ./networking.nix
    ./nix-ld.nix
    ./virt
    # ../modules/nixos/secureboot.nix
    # ../modules/nixos/vscode-server.nix
  ];
}

