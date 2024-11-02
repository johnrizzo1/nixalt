# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  ovn = pkgs.callPackage ./ovn { inherit pkgs; };
  # fmt = pkgs.callPackage ./fmt.nix {};
}
