{ inputs
, lib
, pkgs
, config
, ...
}:
{
  options.services.nix-ld =
    {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        example = true;
        description = "Enable nix-ld to help with dynamically compiled executables on nix";
      };
    };

  config = lib.mkIf config.services.nix-ld.enable {
    nixpkgs.overlays = [
      inputs.nix-alien.overlays.default
    ];

    # programs.nix-ld.enable = true;

    environment.systemPackages = with pkgs; [
      nix-alien
    ];
  };
}
