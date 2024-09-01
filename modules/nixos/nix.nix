{ lib, inputs, ... }: {
  # programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  #   # Add any missing dynamic libraries for unpackaged programs
  #   # here, NOT in environment.systemPackages
  # ];

  nix = {
    extraOptions = "experimental-features = nix-command flakes";

    settings = {
      allowed-users = ["*"];
      cores = 0;
      max-jobs = "auto";
      require-sigs = true;
      sandbox = true;
      system-features = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      trusted-users = ["root" "@wheel"];
      trusted-substituters = ["https://nix-community.cachix.org"];
      trusted-public-keys = ["cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="];
      extra-substituters = ["https://nix-community.cachix.org"];
      extra-trusted-public-keys = ["nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };

    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
    ];
  };
}