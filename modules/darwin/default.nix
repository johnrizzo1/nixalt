{ lib, pkgs, inputs, ... }:
{
  imports = [
    ../common/nix.nix
    ../common/nixpkgs.nix
    ./fonts.nix
    ./packages.nix
    ./_1password.nix
  ];
}
