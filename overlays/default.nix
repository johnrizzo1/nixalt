{inputs, ...}: let
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };

  # darwin-packages = final: _prev: {
  #   darwin = import inputs.nixpkgs-darwin {
  #     system = final.system;
  #     config.allowUnfree = true;
  #   };
  # };
in [
  additions
  modifications
  unstable-packages
  stable-packages
  # darwin-packages
  # inputs.nix.overlays.default
  # inputs.proxmox-nixos.overlays.x86_64-linux
  # inputs.jujutsu.overlays.default
  # inputs.zig.overlays.default
]