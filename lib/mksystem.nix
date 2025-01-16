# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{ nixpkgs, inputs, }:
name:
{ system, user, isWSL ? false, isHypervisor ? false, }:
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
  hmModules =
    if pkgs.stdenv.isDarwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;
  determinate =
    if pkgs.stdenv.isDarwin
    then inputs.determinate.darwinModules.default
    else inputs.determinate.nixosModules.default;
  securebootModules =
    if pkgs.stdenv.isLinux
    then inputs.lanzaboote.nixosModules.lanzaboote
    else { };
  commonConfig =
    if pkgs.stdenv.isLinux
    then ../machines/common/nixos.nix
    else ../machines/common/darwin.nix;

in
systemFunc rec {
  inherit system;

  modules = [
    ../machines/common/nix.nix
    ../machines/common/nixpkgs.nix
    ../machines/common
    ../modules

    securebootModules

    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else { })

    # For vscode server
    # inputs.nix-alien.overlays.default
    inputs.vscode-server.nixosModules.default

    commonConfig
    machineConfig
    userOSConfig
    hmModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = false;
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
        currentSystemName = name;
        currentSystemUser = user;
      };
    }
  ];
}
