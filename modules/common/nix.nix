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
	"https://ai.cachix.org/"
        "https://cache.nixos.org/"
        "https://devenv.cachix.org"
        "https://nix-community.cachix.org"
        "https://cuda-maintainers.cachix.org"
	"https://numtide.cachix.org"
      ];
      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
	"ai.cachix.org-1:N9dzRK+alWwoKXQlnn0H6aUx0lU/mspIoz8hMvGvbbc="
      	"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      	"cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      	"numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
      trusted-substituters = [
	"https://ai.cachix.org"
      	"https://cache.nixos.org/"
        "https://devenv.cachix.org"
      	"https://nix-community.cachix.org"
      	"https://cuda-maintainers.cachix.org"
      	"https://numtide.cachix.org" 
      ];
      trusted-users =
        lib.optionals pkgs.stdenv.isLinux [
          "root"
          "jrizzo"
        ]
        ++ lib.optionals pkgs.stdenv.isDarwin [ "@admin" ];
    };

    gc = {
      automatic = false;
      options = "--delete-older-than 7d";
      # interval = {
      #   Hour = 3;
      #   Minute = 15;
      #   Weekday = 6;
      # }
    };
  };
}
