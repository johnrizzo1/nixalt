# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # build-switch = pkgs.callPackage ./build-switch {};
  fmt = pkgs.callPackage ./fmt {};
}
