{ lib, ... }:
{
  imports = [
    ../common/nix.nix
    ../common/nixpkgs.nix
    ./networking.nix
    ./nix-ld.nix
    ./secureboot.nix
    ./virt
    # ../vscode-server.nix
  ];
}

