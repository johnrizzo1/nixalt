{ lib, pkgs, inputs, ... }:
{
  imports = [
    ../common/nix.nix
    ./fonts.nix
    ./packages.nix
    ./_1password.nix
  ];
}
