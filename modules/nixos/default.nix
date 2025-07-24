{ lib, ... }:
{
  imports = [
    ./networking.nix
    ./nix-ld.nix
    ./secureboot.nix
    ./virt
  ];
}

