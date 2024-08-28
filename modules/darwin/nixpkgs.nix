# { inputs, lib, ... }: {
{ ... }: {
  nixpkgs.config = {
    allowUnfree = true;    
    # allowUnfreePredicate = 
    #   pkg: builtins.elem (lib.getName pkg) [
    #     "1password-gui"
    #     "_1password"
    #     "_1password-cli"
    #   ];
  };
}