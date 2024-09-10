{ inputs, lib, ... }: {
  imports = [
    inputs.nix-ld.nixosModules.nix-ld
  ];

  programs.nix-ld.dev.enable = true;
}