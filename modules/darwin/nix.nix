{ lib
, inputs
, ...
}:
{
  nix = {
    enable = true;
    settings = {
      trusted-users = [ "@admin" ];
      trusted-substituters = [ "https://nix-community.cachix.org" ];
      extra-substituters = [ "https://nix-community.cachix.org" ];
      extra-trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    
    gc = {
      automatic = false;
      options = "--delete-older-than 7d";
      # interval = {
      #   Hour = 3;
      #   Minute = 15;
      #   Weekday = 6;
      # };
    };

    registry = {
      nixpkgs.flake = inputs.nixpkgs-darwin;
    };

    nixPath = [
      "nixpkgs=${inputs.nixpkgs-darwin}"
    ];
  };

  services.nix-daemon.enable = true;
}
