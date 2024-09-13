{ 
  ezModules,
  lib,
  ...
} : {
  imports = lib.attrValues {
    inherit (ezModules)
      nix
      nixpkgs
      fonts
      packages
      _1password
      ;
  };
}