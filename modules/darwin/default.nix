{ lib, ... }:
{
  imports = [
    ../common/nix.nix
    ./fonts.nix
    ./packages.nix
    ./_1password.nix
  ];

  nix = {
    registry = lib.optionals pkgs.stdenv.isDarwin {
      nixpkgs.flake = inputs.nixpkgs-darwin;
    };
    nixPath = lib.optionals pkgs.stdenv.isDarwin {
      nixpkgs = "${inputs.nixpkgs-darwin}";
    };
  };
}
