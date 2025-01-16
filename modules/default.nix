{ lib, ... }:
{
  imports = [
    ./desktop.nix
    ./nix-ld.nix
    ./secureboot.nix
    ./virt
    # ../vscode-server.nix
  ];
}

