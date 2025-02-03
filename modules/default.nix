{ lib, pkgs, ... }:
{
  imports = [
    ./virt-client.nix
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    ./desktop.nix
    ./nix-ld.nix
    ./hypervisor.nix
    ./gns3.nix
    ./secureboot.nix
  ];
}
