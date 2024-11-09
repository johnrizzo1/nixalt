# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ nixpkgs
, overlays
, inputs
,
}:
name:
{ system
, user
, darwin ? false
, isWSL ? false
, isHypervisor ? false
,
}:
let
  pkgs = import nixpkgs { inherit system; };

  # The config files for this system.
  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/${if darwin then "darwin" else "nixos"}.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  # NixOS vs nix-darwin functionst
  systemFunc =
    if darwin
    then inputs.nix-darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;
  determinate =
    if darwin
    then inputs.determinate.darwinModules.default
    else inputs.determinate.nixosModules.default;
  secureboot =
    if pkgs.stdenv.isLinux
    then inputs.lanzaboote.nixosModules.lanzaboote
    else { };
in
systemFunc rec {
  inherit system;

  modules = [
    # determinate

    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    # { nixpkgs.overlays = overlays; }
    ../overlays
    ../modules/common/nixpkgs.nix

    secureboot

    # (if isHypervisor then inputs.proxmox-nixos.nixosModules.proxmox-ve else {})
    # inputs.proxmox-nixos.nixosModules.proxmox-ve
    # Bring in WSL if this is a WSL build
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else { })

    machineConfig
    userOSConfig
    home-manager.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        users.${user} = import userHMConfig {
          inherit isWSL isHypervisor inputs;
        };
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        inherit isWSL isHypervisor inputs;

        currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
      };
    }
  ];
}
