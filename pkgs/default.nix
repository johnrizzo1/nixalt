# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  # fmt = pkgs.callPackage ./fmt.nix {};
  # ovn = pkgs.callPackage ./ovn.nix { };
}
