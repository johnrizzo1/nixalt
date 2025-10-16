{ lib
, inputs
, pkgs
, ...
}:

{
  nix = {
    # enable = true;
    package = pkgs.nixVersions.stable;
    settings = {
      # keep-derivations = true;
      # keep-outputs = true;
      allowed-users = [ "*" ];
      auto-optimise-store = false;
      cores = lib.mkDefault 0;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      extra-sandbox-paths = [ ];
      max-jobs = "auto";
      require-sigs = true;
      sandbox = true;
      substituters = [
        "https://cache.nixos.org/"
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"
      ];
      system-features = [
	"apple-virt"
        "kvm"
        "nixos-test"
        "benchmark"
        "big-parallel"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      	"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      trusted-substituters = [
      	"https://cache.nixos.org/"
        "https://devenv.cachix.org"
      	"https://nix-community.cachix.org"
      ];
      trusted-users =
        lib.optionals pkgs.stdenv.isLinux [
          "root"
          "jrizzo"
        ]
        ++ lib.optionals pkgs.stdenv.isDarwin [ "@admin" ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
      # interval = {
      #   Hour = 3;
      #   Minute = 15;
      #   Weekday = 6;
      # }
    };
  };
}
