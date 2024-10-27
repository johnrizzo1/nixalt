{ inputs
, lib
, pkgs
, ...
}: {
  nixpkgs.overlays = [
    inputs.nix-alien.overlays.default
  ];

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    nix-alien
  ];
}
