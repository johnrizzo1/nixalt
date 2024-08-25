{ 
  ezModules, 
  pkgs,
  lib,
  ...
} : {
  imports = lib.attrValues {
    inherit (ezModules)
      nix
      nixpkgs
      fonts
      packages
      ;
  };
}