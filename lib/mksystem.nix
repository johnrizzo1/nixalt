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
  commonConfig = ../machines/common;

  # NixOS vs nix-darwin functions
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
    else {};
in
systemFunc rec {
  inherit system;

  modules = [
    securebootModules

    (if isWSL then inputs.nixos-wsl.nixosModules.wsl else {})

    # For vscode server
    # inputs.nix-alien.overlays.default
    # inputs.vscode-server.nixosModules.default

    (if pkgs.stdenv.isLinux then ../modules/desktop.nix else {})
    (if pkgs.stdenv.isLinux then ../modules/gns3.nix else {})
    (if pkgs.stdenv.isLinux then ../modules/hypervisor.nix else {})
    (if pkgs.stdenv.isLinux then ../modules/nix-ld.nix else {})
    (if pkgs.stdenv.isLinux then ../modules/secureboot.nix else {})
    (if pkgs.stdenv.isLinux then ../modules/virt-client.nix else {})

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
          inherit isWSL inputs;
        };
      };
    }

    # We expose some extra arguments so that our modules can parameterize
    # better based on these values.
    {
      config._module.args = {
        inherit isWSL inputs;
        currentSystemName = name;
        currentSystemUser = user;
      };
    }
  ];
}
