{ 
  ezModules,
  lib,
  ...
} : {
  imports = lib.attrValues {
    inherit (ezModules)
      nix
      nixpkgs
      # fonts
      # packages
      ;
  };

  # home.stateVersion = "24.05";
}