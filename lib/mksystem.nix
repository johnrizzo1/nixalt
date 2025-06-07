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
, isWSL ? false
, isHypervisor ? false
,
}:
let
  pkgs = import nixpkgs { inherit system; };

  # The config files for this system.
  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/${if pkgs.stdenv.isDarwin then "darwin" else "nixos"}.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  # NixOS vs nix-darwin functionst
  systemFunc =
    if pkgs.stdenv.isDarwin
    then inputs.nix-darwin.lib.darwinSystem
    else nixpkgs.lib.nixosSystem;
  home-manager =
    if pkgs.stdenv.isDarwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;
  secureboot =
    if pkgs.stdenv.isLinux
    then inputs.lanzaboote.nixosModules.lanzaboote
    else { };
in
systemFunc rec {
  inherit system;

  modules = [
    # Apply our overlays. Overlays are keyed by system type so we have
    # to go through and apply our system type. We do this first so
    # the overlays are available globally.
    { nixpkgs.overlays = overlays; }
    ../modules/common/nix.nix
    ../modules/common/nixpkgs.nix

    secureboot

    # Bring in WSL if this is a WSL build
    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else { })

    # For vscode server
    # inputs.nix-alien.overlays.default
    # (if isWSL then inputs.vscode-server.nixosModules.wsl else { })

    (if pkgs.stdenv.isLinux or pkgs.stdenv.isWSL then inputs.vscode-server.nixosModules.default else { })
    (if pkgs.stdenv.isLinux then inputs.portainer-on-nixos.nixosModules.portainer else { })

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

        # currentSystem = system;
        currentSystemName = name;
        currentSystemUser = user;
      };
    }
  ];
}
