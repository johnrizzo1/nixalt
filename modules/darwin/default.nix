{ lib, ... }: {
  imports = [
    # ./nix.nix
    # ./nixpkgs.nix
    ./fonts.nix
    ./packages.nix
    ./_1password.nix
  ];
}
